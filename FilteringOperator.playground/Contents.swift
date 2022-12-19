import RxSwift

/**
 onNext로 받아오는 이벤트등을 선택적으로 취할 수 있게 해주는 연산자들
 기존 Array의 함수인 Filter와 거의 비슷한 기능들이 있다.
 */

let disposeBag = DisposeBag()
/*
 Complete, Error등의 일시정지 이벤트는 허용하지만,
 Next 이벤트를 무시하는 연산자.
 언제 쓰는가?
 */
print("================== ignoreElemets ==================")
let 취침모드 = PublishSubject<String>()
취침모드
    .ignoreElements()
    .subscribe { _ in
        print("햇빛")
    }
    .disposed(by: disposeBag)

취침모드.onNext("알람소리")         //무시
취침모드.onNext("알람소리")         //무시
취침모드.onNext("알람소리")         //무시

//취침모드.onCompleted()

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

/*
 특정 요소들을 무시하는 연산자
 .skip연산자로 주는 index파라미터 만큼 요소를 무시한다.
 */
print("================== Skip ==================")
Observable.of("커피", "라테", "카푸치노", "에이드", "그린티", "아이스티")
    .skip(3)                        //3번째 index의 값인 "에이드" 이전의 값은 모두 무시한다.
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 .skip 로직 내에서 while 반복문을 돌려,
 false가 되는 시점부터 Skip을 멈추고 이 후 요소를 방출한다.
 즉, false 이전까지는 무시(filter와 반대)
 */
print("================== SkipWhile ==================")
Observable.of("커피", "라테", "카푸치노", "에이드", "그린티", "아이스티", "우유", "참기름")
    .skip(while: {
        $0 != "그린티"
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 .skip(until:)
 다른 옵저버블에 기반한 요소들에 영향을 받는 연산자
 다른 옵저버블에서 어떤 값이 방출되기 전까지는 작동하지 않는다.
 */
print("================== SkipUntil ==================")
let 손님 = PublishSubject<String>()
let 문여는시간 = PublishSubject<String>()

손님
    .skip(until: 문여는시간)     //다른 옵저버벌이 요소를 방출하기 전까지 '손님'옵저버블은 작동하지 않는다.
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

손님.onNext("손님1")
손님.onNext("손님2")
문여는시간.onNext("Open!!")
손님.onNext("손님3")

/*
 .skip의 반대 개념
 주어진 인덱스만큼 방출한다.
 */
print("================== take ==================")
Observable.of("금", "은", "동", "4위", "5위")
    .take(3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 .skip(while:)과는 반대 개념
 .skip(while:)이 false값이 되는 순간부터 그 이후의 요소를 방출했다면
 true인 동안 요소를 방출한다.
 */
print("================== take(while:) ==================")
Observable.of("금", "은", "동", "4위", "5위")
    .take(while: {
        $0 != "동"       //"동" != "동"은 false를 Return하므로 '금', '은'만 방출
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 .skip(until:)과 반대
 .skip(until:)이 다른 옵저버블의 요소가 방출된 이후에 작동하는 연산자라면,
 take(until:)은 다른 옵저버블의 요소가 방출되기 전까지만 작동하는 연산자.
 */
print("================== take(until: ) ==================")
let 수강신청 = PublishSubject<String>()
let 수강마감 = PublishSubject<String>()

수강신청
    .take(until: 수강마감)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

수강신청.onNext("학생1")
수강신청.onNext("학생2")
수강신청.onNext("학생3")
수강마감.onNext("마감!")
수강신청.onNext("학생4")

/*
 시퀀스의 index와 Element를 같이 방출한다.
 */
print("================== enumerated ==================")
Observable.of("금", "은", "동", "4위", "5위")
    .enumerated()
    .take(while: {
        $0.index < 3
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 연달아 같은 값이 이어질 때 중복된 값을 제거하는 연산자.
 단, 똑같은 요소가 있어도 연달아 나오지 않는다면 제거되지는 않는다.
 */
print("================== distinctUntilChanged ==================")
Observable.of("저는", "저는", "앵무새", "앵무새", "앵무새", "앵무새", "입니다", "입니다", "저는", "누구죠?")
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

