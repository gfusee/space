import Space
import Counter
import XCTest

let COUNTER_ADDRESS = "counter"

final class CounterTests: ContractTestCase {
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: COUNTER_ADDRESS)
        ]
    }
    
    func testDeployCounterInitialValueZero() throws {
        let contract = try Counter.testable(
            COUNTER_ADDRESS,
            initialValue: 0
        )
    }
}
