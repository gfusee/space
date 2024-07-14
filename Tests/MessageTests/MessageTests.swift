import XCTest
import MultiversX

@Contract struct MessageContract {
    
    @Storage(key: "address") var address: Address
    
    init() {
        self.address = Message.caller
    }
    
    public func getCallerAddress() -> Address {
        return Message.caller
    }
    
    public func getStorageAddress() -> Address {
        return self.address
    }

    public func getEgldValue() -> BigUint {
        return Message.egldValue
    }
}

final class MessageTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "adder"),
            WorldAccount(
                address: "user",
                balance: 1000
            )
        ]
    }
    
    func testGetCallerInInitNotSet() throws {
        let contract = try MessageContract.testable("adder")
        
        let storedAddress = try contract.getStorageAddress()
        
        XCTAssertEqual(storedAddress.hexDescription, "0000000000000000000061646465725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCallerInInit() throws {
        let contract = try MessageContract.testable(
            "adder",
            callerAddress: "user"
        )
        
        let storedAddress = try contract.getStorageAddress()
        
        XCTAssertEqual(storedAddress.hexDescription, "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCallerNotSet() throws {
        let contract = try MessageContract.testable("adder")
        
        let contractAddress = try contract.getCallerAddress()
        
        XCTAssertEqual(contractAddress.hexDescription, "0000000000000000000061646465725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCaller() throws {
        let contract = try MessageContract.testable("adder")
        
        let contractAddress = try contract.getCallerAddress(
            callerAddress: "user"
        )
        
        XCTAssertEqual(contractAddress.hexDescription, "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }

    func testGetEgldValueNoValue() throws {
        let contract = try MessageContract.testable("adder")
        
        let value = try contract.getEgldValue()
        
        XCTAssertEqual(value, 0)
    }

    func testGetEgldValue() throws {
        let contract = try MessageContract.testable("adder")
        
        let value = try contract.getEgldValue(callerAddress: "user", egldValue: 100)
        
        XCTAssertEqual(value, 100)
    }
}
