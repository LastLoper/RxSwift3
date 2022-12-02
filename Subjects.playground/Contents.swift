import RxSwift

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

//위에서 이미 onCompleted로 Observable을 종료했기 때문에
//이후로 둑독한 세번째 구독자는 이후로 onNext를 받는다 하더라도 어떠한 이벤트도 방출하지 않고 종료된다.
publicS
    .subscribe {
        print("세번째 구독자 : ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

publicS.onNext("Can you hear me?")

print("## BehaviorSubject")
//BevaviorSubject는 반드시 초기값을 지정해야 한다.
//직전의 값과 이후 새로운 값을 받는다.
enum SubjectError: Error {
    case error1
}
let behaviorS = BehaviorSubject<String>(value: "0. 초기값")
behaviorS.onNext("1. 첫번째 값")

behaviorS.subscribe {
    print("첫번째 구독자 : ", $0.element ?? $0)
}
.disposed(by: disposeBag)

//behaviorS.onError(SubjectError.error1)

behaviorS.subscribe {
    print("두번째 구독자 : ", $0.element ?? $0)
}
.disposed(by: disposeBag)

//Observable 안에서만 꺼낼 수 있는 값을 바깥에서도 쓰기 위해서
//BehaviorSubject는 value()를 지원한다.
let value = try? behaviorS.value()
print(value)

print("## ReplaySubject")
//초기 버퍼값을 정하기 위해 create를 이용해야 한다.
let replayS = ReplaySubject<String>.create(bufferSize: 1)

replayS.onNext("1. 첫째")
replayS.onNext("2. 둘째")
replayS.onNext("3. 셋째")

replayS.subscribe {
    print("첫번째 구독 : ", $0.element ?? $0)
}.disposed(by: disposeBag)

replayS.subscribe {
    print("두번째 구독 : ", $0.element ?? $0)
}.disposed(by: disposeBag)

replayS.onNext("4. 넷째")
replayS.onError(SubjectError.error1)
replayS.dispose()

replayS.subscribe {
    print("세번째 구독 : ", $0.element ?? $0)
}.disposed(by: disposeBag)
