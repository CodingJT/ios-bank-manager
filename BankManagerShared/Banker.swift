import Foundation

protocol Banker {
    func task(of customer: Customer)
    var taskType: TaskType { get }
    var taskTime: TimeInterval { get }
}

extension Banker {
    func task(of customer: Customer) {
        Thread.sleep(forTimeInterval: taskTime)
        BankManager.shared.increaseTotalCustomer()
    }
}

struct DepositBanker: Banker {
    let taskType = TaskType.deposit
    let taskTime = 0.7
}

struct LoanBanker: Banker {
    let taskType = TaskType.loan
    let taskTime = 1.1
}

struct GeneralBanker: Banker {
    let taskType = TaskType.deposit
    let taskTime = 0.7
}
