## 🏦 은행 창구 매니저

#### 🗓️ 프로젝트 기간: 2021.12.20 - 2021.12.31

#### Contributor
🐹 [제리](https://github.com/llghdud921)
😆 [제이티](https://github.com/CodingJT)

## 프로젝트 설명

### ✔️ 구현모습

![](https://i.imgur.com/xlQqiTS.png)   
...  

![](https://i.imgur.com/0NLNKpO.png)


[은행 창구 매니저]

✔️ 은행에서 일어나는 일을 프로그래밍적 사고 관점에서 구현

✔️ 대출 업무 은행원과 예금 업무 은행원이 일을 동시에 처리할 수 있도록 코드 구현

✔️ 은행원과 고객 사이에 교류할 수 있도록 코드 구현

<br>

## Step 1. Queue 타입 구현

### 💡 1-1. keyword

- LinkedList, Queue
- struct vs Class

<br>

### 🤔 1-2. 고민했던 점

**LinkedList의 타입 sturct vs class**
초기에는 LinkedList를 struct로 구현하였지만 LinkedList내부의 node는 참조타입인 클래스로 구현이 되어있었기 때문에 예시로 아래 코드를 실행하는 경우 LinkedList 내부의 node가 정상적으로 변하지 않는 문제가 발생했습니다.
```swift
var queue = Queue<Int>()
queue.enqueue(1)
queue.enqueue(2)

var queue2 = queue
queue2.enqueue(3)
```

<img src="https://i.imgur.com/FwzlsI6.png" width="400" height="300">

따라서 Linkedlist와 같이 참조타입의 Node를 가지는 경우, Node의 참조 관리를 위해 class로 구현해야한다고 생각했습니다.

<br>

**LinkedList 양방향 vs 단방향?**

LinkedList의 타입을 양방향으로 지정해야할지 고민하였습니다. tail을 head.previous로 접근하는 방법을 구현할지에 대한 고민이었다.
Queue에서 LinkedList를 사용할 때 단방향이어도 문제가 없다고 판단하여 단방향으로 구현하였다.

<br>

**typealias 사용**

LinkedList 타입을 구현되지 않은 상황에 대응하는 방식으로 typealias를 적용해 보았습니다.

아래 코드와 같이 LinkedList에 제네릭타입을 사용하는 코드를 미리 구현해서 코드 수정 시 대응하기 수월하였습니다.

```swift
// LinkedList 타입이 구현되지 않은 상황
typealias LinkedList = Array

private var items: LinkedList<T>

// LinkedList 구현 완료
private var items: LinkedList<T>
```

<br>



## Step 2. 타입 구현 및 콘솔앱 구현

### 💡 2-1. keyword
- Delegate 구현
- 은행, 고객, 은행원 등 작성한 타입 활용

<br>

### 🤔 2-2. 고민했던 점

**총 업무 시간을 계산하는 주체**

- 은행원의 업무 문제가 생긴다면 은행원이 처리하지 못한 시간이라고 판단하여 은행원이 업무 시간을 결정하는 주체로 코드를 작성하였습니다.
- 해당 기능은 delegate 패턴을 이용해서 구현하였으며 STEP 2는 은행원이 1명이어서 단순하게 처리 시간을 더해주는 코드를 작성하였습니다.

``` swift
print("\(customer.customerNumber)번 고객 업무 시작")
delegate?.checkTime()
print("\(customer.customerNumber)번 고객 업무 완료")
delegate?.checkCustomer()
```

<br>

**delegate 패턴으로 구현**

Banker 내에서 Bank의 프로퍼티 변경을 위해서 Banker의 일을 Bank에게 위임하는 형태로 구현하였습니다.
``` swift
protocol BankDelegate {
    func checkTime()
    func checkCustomer()
}

extension Bank: BankDelegate {
    func checkCustomer() {
        let customerCountAtOnce = 1
        totalCustomer += customerCountAtOnce
    }

    func checkTime() {
        let secondsAtOnce: TimeInterval = 0.7
        totalTime += secondsAtOnce
    }
}
```

<br>

**Bank를 class로 구현**
- Delegate 패턴을 사용하며 문제가 발생하였습니다. Delegate Protocol을 채택한 Bank 타입이 struct인 것이 문제의 원인이었습니다.
- 해당 문제를 해결하기 위해 Bank를 struct로 구현하는 방식을 포기하자는 결론이 나왔습니다.

<br>

**error handling**
- customer가 nil인 경우에 customer의 업무를 처리하려는 taskWithError()가 실행되면 notExistCustomer 에러를 발생시켰습니다.
- 해당 에러를 처리하는 메서드인 task()를 따로 구현하였습니다.

``` swift
private func taskWithError() throws {
    guard let customer = customer else {
        throw CustomerError.notExistCustomer
    }
    ...
    
private func task() {
    do {
        try taskWithError()
    } catch {
        print(error.localizedDescription)
    }
}
```

<br>

**속성을 정할 수 있는 메서드 구현**

```swift
// 사용법
input(with: "입력 : ", useTrim: true)

// 구현 코드
func input(with message: String = "", useTrim: Bool = false) throws -> String {
    ...
    if useTrim == true {
        inputValue = inputValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return inputValue
}
```

- 메서드 파라미터에서 메서드 내부 속성을 정의할 수 있도록 코드를 구현하였습니다.
- input 메서드를 사용한 것만으로 print()와 readline이 동시에 가능하게 만들었고 결과값에 trim 설정 또한 지정할 수 있게 만들었습니다.

<br>

## Step 3. 다중처리

### 💡 3-1. keyword

- GCD
- protocol 추상화

<br>

### 🤔 3-2. 고민했던 점

**GCD 구현**

- DispatchQueue
2명의 예금업무 은행원과 1명의 대출업무 은행원의 처리를 동시에 구현하기 위해서 concurrent queue인 global()을 이용하였습니다.

- DispatchSemaphore
각 업무에 대해 DispatchSemaphore를 생성하였고 각 업무의 은행원의 수만큼 semaphore의 파라미터를 지정하여 접근할 수 있는 스레드의 수를 허용하게 하였습니다.

    ```swift
    let loanSemaphore = DispatchSemaphore(value: loanBankerCount)
    let depositSemaphore = DispatchSemaphore(value: depositBankerCount)
    DispatchGroup
    ```

customer마다 비동기적으로 처리되는 업무를 banker 그룹으로 묶어서 작업 상태를 추적하였고 wait()을 이용하여 모든 작업이 수행을 완료하기까지 기다린 후 다음 코드를 진행하였습니다.

<br>

**은행원을 protocol 추상화**

- 은행원의 메소드와 프로퍼티를 protocol에 추상화
업무 종류를 코드로 구현하기 위해 TaskType이라는 enum 타입을 구현하였고 extension 코드를 이용하여 기본 구현을 작성하였습니다.
- 각 업무을 가진 은행원 구현체를 구현
예금 업무, 대출 업무를 하는 은행원 구현체를 각각 만들어서 업무와 업무 처리 시간을 명시하였습니다.
