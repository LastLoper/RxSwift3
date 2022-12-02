import Foundation
import RxSwift

//어떤 형태의 요소를 방출할 것인지 <>로 지정한다.
//just => 1개의 요소만 방출하는 오퍼레이터
//단 1개의 Observable Sequence가 만들어진다.
print("## just")
Observable<Int>.just(1)

//of -> 1개 이상의 이벤트, 요소를 넣을 수 있다. 쉼표로 구분
//각 요소를 순차적을 방출하는 Observable Sequence가 만들어진다.
print("## of 1")
Observable<Int>.of(1, 2, 3, 4, 5)

//Observable은 타입추론을 통해 Sequence를 생성한다.
//아래와 같은 경우 1개의 Array를 방출하는, just와 같은 기능을 한다.
print("## of 2")
Observable.of([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })

//from -> Array형태의 요소만 받아 각 요소를 꺼내서 하나씩 방출하는 Sequence를 만든다.
//타입을 지정하지 않은 of연산자와는 다르게 배열의 요소를 하나씩 출력한다.
print("## from")
Observable.from([1, 2, 3, 4, 5])
    .subscribe ( onNext: {
        print($0)
    })

/**
 Observable은 선언만 해서는 아무런 작동을 하지 않는다.
 반드시, subscribe를 해줘야 한다.
 */

//subscribe 사용법 1
//onNext 없이 그냥 이벤트를 방출 한다.
//마지막에 completed 이벤트 역시 출력 된다.
print("## subscribe 1")
Observable.of(1, 2, 3)
    .subscribe {
        print($0)
    }

//subscribe 사용법 2
//element가 있는지 확인 하여 이벤트를 출력한다.
print("## subscribe 2")
Observable.of(1, 2, 3)
    .subscribe {
        if let element = $0.element {
            print(element)
        }
    }

//subscribe 사용법 3
//가장 일반적인 사용법, onNext를 명시한다.
print("## subscribe 3")
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })

//empty -> 요소를 하나도 가지지 않는,
//카운트 0인 Observable Sequence를 방출한다.
//onCompleted 외에는 아무런 값도 방출하지 않는다.
print("## empty 1")
Observable.empty()
    .subscribe {
        print($0)
    }

//Void 타입을 지정해주면 그저 완료되었다는, Completed가 출력된다.
//언제 쓸 수 있을까?
//1. 즉시 종료할 수 있는 Observable을 Return하고 싶을 때
//2. 의도적으로 0개의 값을 가진 Observable을 Return하고 싶을 때
print("## empty 2")
Observable<Void>.empty()
    .subscribe {
        print($0)
    }

//empty 2와 동일한 표현이다.
print("## empty 2-1")
Observable<Void>.empty()
    .subscribe(onNext: {
        
    },
    onCompleted : {
        print("completed")
    })

//never -> 그 어떤 Sequence도 방출하지 않는 연산자
//확인을 위해서 <Void> .debug()를 사용해야 한다.
print("## never")
Observable<Void>.never()
    .debug("never")
    .subscribe(onNext: {
        print($0)
    },
    onCompleted: {
        print("completed")
    })

//range -> Array에 대해 일정 범위 만큼 Sequence를 가진다.
print("## range")
Observable.range(start: 1, count: 9)
    .subscribe(onNext: {
        print("2 * \($0) = \(2*$0)")
    })

/**
 Observable을 subscribe(구독)했다면 반대로 취소도 가능해야 한다.
 Observable 구독을 취소함으로써 종료시킬 수도 있다.
 이때, 쓰는 개념이 Dispose.
 */
print("## dispose")
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })
    .dispose()      //구독을 취소

//DisposeBag -> 방출된 이벤트를 하나로 모아 일괄 구독 취소하는.. 개념?
//DisposeBag이 할당 해제될때 모든 Dispose 역시 메모리에서 날려버린다.?
print("## disposeBag")
let disposeBag = DisposeBag()
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)      //구독을 취소

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

//오류를 포함한 create
//오류가 있으면 onCompleted가 실행되기 전에 Observable이 종료된다.
print("## create 2")
enum MyError: Error {
    case anError
}

Observable<Int>.create { observer -> Disposable in
    observer.onNext(1)
    observer.onError(MyError.anError)
    observer.onCompleted()
    observer.onNext(2)
    return Disposables.create()
}
.subscribe(
    onNext: {
        print($0)
    },
    onError: {
        print($0.localizedDescription)
    },
    onCompleted: {
        print("completed")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)

//Observable을 생성할 수 있는 또다른 방식
//deffered -> subscribe를 기다리는 Observable을 만드는 대신, 각 subscribe에게 새롭게 Observable 항목을 제공한다.
//Observable factory를 만드는 방식이다.
//deferred를 쓰지 않은 Observable을 쓴 것과 같은 Sequence를 방출한다.
print("## deffered 1")
Observable.deferred {
    Observable.of(1, 2, 3)
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

//즉, 조건에 따라 다른 Observable을 만들어 낼 수 있다.
//말 그대로 Observable을 만들어내는 공장이다.
print("## deffered 2")
var 뒤집기: Bool = false
let factory: Observable<String> = Observable.deferred {
    뒤집기 = !뒤집기
    
    if 뒤집기 {
        return Observable.of("😎")
    } else {
        return Observable.of("😒")
    }
}

for _ in 0...3 {
    factory.subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
}
