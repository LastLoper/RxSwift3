## Observable
```swift
//of -> 1개 이상의 이벤트, 요소를 넣을 수 있다. 쉼표로 구분
//각 요소를 순차적을 방출하는 Observable Sequence가 만들어진다.
print("## of 1")
Observable<Int>.of(1, 2, 3, 4, 5)
    .subscribe(onNext: {
        print($0)
    })
    
//가장 일반적인 사용법, onNext를 명시한다.
print("## subscribe 3")
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })
    
//DisposeBag -> dispose 객체가 메모리 해제될 때 일괄적을 구독 취소한다.
print("## disposeBag")
let disposeBag = DisposeBag()
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)      //disposeBag에 이 subscribe를 저장.
    
//Create -> escaping 클로저
//Observable Sequence에 쉽게 값을 추가할 수 있도록 해준다.
print("## create 1")
Observable.create { observer -> Disposable in
    observer.onNext(1)
//    observer.on(.next(1))     //136번 줄과 같음
    observer.onCompleted()
//    observer.on(.completed)   //138번 줄과 같음
    observer.onNext(2)
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)    
```

## Traits
```swift
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
```

## Subjects
```swift
//현업에서는 Observable이자 Observer가 필요하다. 이를 Subject라고 한다.
//종류
//1. PublishSubject : 빈 상태로 시작해서 구독을 시작힌 시점 이후로 새로운 값만을 subscriber에 방출한다.
//2. BehaviorSubject : 하나의 초기값을 가진 상태로 시작, 새로운 subscriber에게 최신값과 새로운 값들을 방출한다.
//3. ReplaySubject : 버퍼를 두고 초기화하며, 버퍼 사이즈 만큼의 값들을 유지하면서 새로운 subscriber에게 방출한다.

let disposeBag = DisposeBag()

print("## PublishSubject")
let publicS = PublishSubject<String>()
publicS.onNext("1. 안녕하세요!")

let 구독자1 = publicS
    .subscribe (onNext: {
        print("첫번째 구독자 : \($0)")
    })

publicS.onNext("2. 반가워요")
publicS.onNext("3. Hello~")

구독자1.dispose()

let 구독자2 = publicS
    .subscribe (onNext: {
        print("두번째 구독자 : \($0)")
    })

publicS.onNext("4. Nice to meet you")
publicS.onCompleted()

publicS.onNext("5. What do you do?")
구독자2.dispose()
```

## FilteringOperator
```swift
/*
 at파라미터로 전달하는 index에 해당하는 값만 방출하는 연산자
 n번째 요소만 출력하고 나머지 next에 대해서는 무시한다.
 */
print("================== Element(at:) ==================")
let 두번울면깨는사람 = PublishSubject<String>()

두번울면깨는사람
    .element(at: 2)
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBag)

두번울면깨는사람.onNext("알람소리")         //index : 0
두번울면깨는사람.onNext("알람소리")         //index : 1
두번울면깨는사람.onNext("일어났다!")        //index : 2
두번울면깨는사람.onNext("알람소리")         //index : 3

/*
 가장 대표적인 연산자
 특정 요소만 내보내는 것이 아닌 조건에 맞는 2개 이상의 요소를 방출하는데 사용하는 연산자.
 기존 Swift의 Array 함수와 동일
 */
print("================== Filter ==================")
Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    .filter { $0 % 2 == 0 }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
```

## TransformingOperator
```swift
/*
 독립된 요소들을 배열로 만든다.
 이때, toArray()는 Observable Type을 Single로 변환한다.
 */
print("================== toArray ==================")
Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onSuccess: {
        print($0)
    })
    .disposed(by: disposeBag)
//["A", "B", "C"]

/*
 기존 Swift의 map과 동일
 */
print("================== map ==================")
Observable.of(Date())
    .map { date -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
    
/*
 필터링 연산자 이해를 위한 예제
 숫자를 11자리 입력했을 때 전화번호 양식으로 변환하여 출력하는 예제
 */
print("================== 전화번호 11자리 ==================")
let input = PublishSubject<Int?>()

let list: [Int] = [1]

input
    .flatMap {
        $0 == nil ? Observable.empty() : Observable.just($0)
    }
    .map { value in
        //flatMap을 지나온 값은 Optional이므로 값을 강제로 보장
        value!
    }
    .skip(while: {
        //0이 나올때까지 Skip
        //0 != 0 은 false이므로 다음 값을 출력        
        $0 != 0
    })
    .take(11)           //0부터 시작한다면, 11자리까지만 받는다.
    .toArray()          //Single타입으로 변환된 배열로 만들지만.
    .asObservable()     //다시 Observable타입으로 변환.
    .map {
        //각 배열의 요소들(Int)을 String으로 변환해서
        //String으로 변환된 요소들을 가진 배열로 변환
        $0.map { "\($0)" }
    }
    .map { numbers in
        //[String]인 숫자 묶음에,
        var numberList = numbers
        numberList.insert("-", at: 3)       //3번째 위치에 -삽입 => 010-
        numberList.insert("-", at: 8)       //8번째 위치에 -삽입 => 010-1234-
        let number = numberList.reduce(" ", +)  //각각의 String을 더한다.
        return number
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

input.onNext(10)
input.onNext(0)
input.onNext(nil)
input.onNext(1)
input.onNext(0)
input.onNext(5)
input.onNext(2)
input.onNext(8)
input.onNext(7)
input.onNext(6)
input.onNext(7)
input.onNext(nil)
input.onNext(4)
input.onNext(1)
input.onNext(3)    
```
