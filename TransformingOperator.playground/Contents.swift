import RxSwift

/**
 변환 연산자.
 subscribe를 통해서, Observable에서 데이터를 준비하는 것 같이 사용 가능하다.
 독립적인 값들을 조합해서 쓰고자할 때 사용할 수 있는 연산자.
 */

let disposeBag = DisposeBag()

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
 만약 Observable<Observable<String>>과 같이 중첩된 Observable은 어떻게 사용할 수 있을까?
 flatMap을 통해 전달받은 Observable의 멤버변수에 접근할 수 있는 연산자다?
 */
print("================== flatMap ==================")
protocol 선수 {
    var 점수: BehaviorSubject<Int> { get }
}

struct 양궁선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 한국_국가대표 = 양궁선수(점수: BehaviorSubject<Int>(value: 10))
let 미국_국가대표 = 양궁선수(점수: BehaviorSubject<Int>(value: 8))

let 올림픽 = PublishSubject<선수>()
올림픽
    .flatMap { 선수 in
        선수.점수
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

올림픽.onNext(한국_국가대표)
한국_국가대표.점수.onNext(10)

올림픽.onNext(미국_국가대표)
한국_국가대표.점수.onNext(10)
미국_국가대표.점수.onNext(9)

/*
 flatMap으로 필터링된 시퀀스들 중 가장 최신의 시퀀스 요소를 가져오는 연산자.
 단, 새로운 시퀀스가 들어오면 그 이전의 시퀀스는 새로운 시퀀스가 들어오기까지만 작동하고 해제된다.
 네트워킹 작업에서 가장 많이 사용된다.
 */
print("================== flatMapLatest ==================")
struct 높이뛰기: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 서울 = 높이뛰기(점수: BehaviorSubject<Int>(value: 7))
let 제주 = 높이뛰기(점수: BehaviorSubject<Int>(value: 6))

let 전국체전 = PublishSubject<선수>()

전국체전
    .flatMapLatest { 선수 in
        선수.점수
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

전국체전.onNext(서울)
서울.점수.onNext(9)
서울.점수.onNext(10)

전국체전.onNext(제주)
서울.점수.onNext(10)        //'제주'라는 새로운 시퀀스가 전국체전에 들어왔기 때문에 '서울'시퀀스는 해제, 따라서 바뀐 서울 점수는 방출 되지 않는다.
제주.점수.onNext(8)
제주.점수.onNext(9)

/*
 Observable을 Observable의 이벤트로 처리해야 할 때가 있다?
 외부적으로 Observable이 종료되는 것을 방지하기 위한 용도로 사용 가능하다.
 Error이벤트를 처리하고 싶을 때 사용.
 */
print("================== Materialize and dematerialize ==================")
enum 반칙: Error {
    case 부정출발
}

struct 달리기선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 김토끼 = 달리기선수(점수: BehaviorSubject<Int>(value: 0))
let 박치타 = 달리기선수(점수: BehaviorSubject<Int>(value: 1))

let 달리기100M = BehaviorSubject<선수>(value: 김토끼)

달리기100M
    .flatMapLatest { 선수 in
        선수.점수
            .materialize()      //값만 받는 것이 아니라 어떤 이벤트인지도 감싸서 결과를 받을 수 있다.
    }
    .filter {
        //해당 이벤트가 에러인지 필터링
        guard let error = $0.error else {
            //에러가 아니라면 통과
            return true
        }
        //에러가 맞다면 출력하고 통과X
        print(error)
        return false
    }
    .dematerialize()        //이벤트로 감싼 것을 풀고 값만을 결과로 받는다.
    .subscribe(onNext: {
        print($0)           //이벤트와 값을 확인
    })
    .disposed(by: disposeBag)

김토끼.점수.onNext(1)
김토끼.점수.onError(반칙.부정출발)
김토끼.점수.onNext(2)

달리기100M.onNext(박치타)

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
