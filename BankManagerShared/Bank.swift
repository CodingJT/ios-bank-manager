import Foundation

struct Bank {
    private let bankers: [Banker]
    private var customerQueue: Queue<Customer>?
    
    private init(bankers : [Banker]) {
        self.bankers = bankers
    }

    init(depositBankerCount: Int, loanBankerCount: Int) {
        var bankerQueue: [Banker] = []
        bankerQueue.append(BankerType: LoanBanker(), count: loanBankerCount)
        bankerQueue.append(BankerType: DepositBanker(), count: depositBankerCount)
        self.init(bankers: bankerQueue)
    }
}

// MARK: - method

extension Bank {
    
    mutating func operate() {
        receiveCustomerQueue()
        BankManager.shared.startTimeCheck()
        open()
        BankManager.shared.endTimeCheck()
        close()
        BankManager.shared.clearTotalValues()
    }
    
    private mutating func receiveCustomerQueue() {
        customerQueue = BankManager.shared.lineUpCustomers()
    }
    
    private func open() {
        let group = DispatchGroup()
        let loanQueue = DispatchQueue(label: TaskType.loan.description)
        let depositQueue = DispatchQueue(label: TaskType.deposit.description)
        while let customer = customerQueue?.dequeue() {
            let dispatchQueue: DispatchQueue
            switch customer.wantToTask {
            case .deposit:
                dispatchQueue = depositQueue
            case .loan:
                dispatchQueue = loanQueue
            }
            dispatchQueue.async(group: group) {
                guard let banker = bankers.first else { return }
                print("\(customer.customerNumber)번 고객 \(dispatchQueue.label)업무 시작")
                assign(customer: customer, to: banker)
                print("\(customer.customerNumber)번 고객 \(dispatchQueue.label)업무 완료")
            }
        }
        group.wait()
    }
    
    private func close() {
        let totalTimeText: String = String(format: "%.2f", BankManager.shared.totalTime)
        let totalCustomer: Int = BankManager.shared.totalCustomer
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(totalCustomer)명이며, 총 업무시간은 \(totalTimeText)초입니다.")
    }
    
    private func assign(customer: Customer, to banker: Banker) {
        banker.task(of: customer)
    }
}

extension Array where Element == Banker {
    mutating func append(BankerType: Banker, count: Int) {
        for _ in 0..<count {
            self.append(BankerType)
        }
    }
}
