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
        let loanSemaphore = DispatchSemaphore(value: 2)
        let depositSemaphore = DispatchSemaphore(value: 1)
        
        let loanQueue = DispatchQueue.global()
        let depositQueue = DispatchQueue.global()
        
        while let customer = customerQueue?.dequeue() {
            switch customer.wantToTask {
            case .deposit:
                depositQueue.async(group: group) {
                    loanSemaphore.wait()
                    assign(customer: customer, to: DepositBanker())
                    loanSemaphore.signal()
                }
            case .loan:
                loanQueue.async(group: group) {
                    depositSemaphore.wait()
                    assign(customer: customer, to: LoanBanker())
                    depositSemaphore.signal()
                }
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
