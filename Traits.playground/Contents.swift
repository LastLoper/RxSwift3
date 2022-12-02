import RxSwift

let disposeBag = DisposeBag()

enum TraitsError: Error {
    case single
    case maybe
    case completable
}

/**
 Single
 Observable을 조금 더 간단하고 직관적으로 쓸 수 있다.
 onSuccess는 onNext와 onCompleted를 합친 것이고 Observable의 onError는 onFailure로 대체할 수 있다.
 주로 네트워크 통신의 성공과 실패, 두 가지 경우의 결과에 대해서만 사용한다.
 */
print("## Single 1")
Single<String>.just("✅")
    .subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("error: \($0)")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

//오류를 포함한 Singler
//asSingle 연산자를 쓰면 클로저 역시 Single클로저를 사용해야 한다.
print("## Single 2")
Observable<String>.create { observer -> Disposable in
    observer.onError(TraitsError.single)
    return Disposables.create()
}
.asSingle()
.subscribe(
    onSuccess: {
        print($0)
    },
    onFailure: {
        print("error : \($0.localizedDescription)")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)

//네트워크 통신에서 JSON 데이터를 가져왔느냐, 아니냐에서 많이 쓰이기도 한다.
print("## Single 3")
struct SomeJSON: Decodable {
    let name: String
}
enum JSONError: Error {
    case decodingError
}
let json1 = """
            {"name": "park"}
            """
let json2 = """
            {"my_name": ""young"}
            """
func decode(json: String) -> Single<SomeJSON> {
    Single<SomeJSON>.create { observer -> Disposable in
        guard let data = json.data(using: .utf8),
              let json = try? JSONDecoder().decode(SomeJSON.self, from: data) else {
            observer(.failure(JSONError.decodingError))
            return Disposables.create()
        }
        
        observer(.success(json))
        return Disposables.create()
    }
}

decode(json: json1)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
    }
    .disposed(by: disposeBag)

//my_name이라는 잘못된 키값으로 들어왔기에 error가 발생함
decode(json: json2)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
    }
    .disposed(by: disposeBag)

/**
 Maybe
 싱글과 비슷하지만, 아무런 값도 내보내지 않는 onComplete 클로저를 방출할 수 있다.
 */
print("## Maybe 1")
Maybe<String>.just("V")
    .subscribe {
        print($0)
    } onError: {
        print($0)
    } onCompleted: {
        print("completed")
    } onDisposed: {
        print("disposed")
    }
    .disposed(by: disposeBag)

//에러를 포함한 Maybe
print("## Maybe 2")
Observable<String>.create { observer -> Disposable in
    observer.onError(TraitsError.maybe)
    return Disposables.create()
}
.asMaybe()
.subscribe {
    print("성공 : \($0)")
} onError: {
    print("에러 : \($0)")
} onCompleted: {
    print("onCompleted")
} onDisposed: {
    print("onDisposed")
}
.disposed(by: disposeBag)

/**
 Completable
 값이 없는 onCompleted와 onError 클로저만을 방출한다.
 Observable은 일단 값을 방출하기 때문에,  asSingle, asMaybe 처럼 Observable을 변환할 수는 없다.
 */
print("## Completable 1")
Completable.create { observer -> Disposable in
    observer(.completed)
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

//Error가 있는 Completable
print("## Completable 2")
Completable.create { observer -> Disposable in
    observer(.error(TraitsError.completable))
    return Disposables.create()
}
.subscribe {
    print("completed")
} onError: {
    print("error : \($0)")
} onDisposed: {
    print("disposed")
}
.disposed(by: disposeBag)
