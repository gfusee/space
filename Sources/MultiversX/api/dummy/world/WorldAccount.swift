#if !WASM
import Foundation
import BigInt

public struct EsdtBalance: Equatable {
    var nonce: UInt64
    var balance: BigInt
    
    
    public init(
        nonce: UInt64,
        balance: BigInt
    ) {
        self.nonce = nonce
        self.balance = balance
    }
}

public struct WorldAccount {
    package var addressData: Data
    package var balance: BigInt
    package var esdtBalances: [Data : [EsdtBalance]]
    package var owner: Data?
    
    public init(
        address: String,
        balance: BigInt = 0,
        esdtBalances: [String : [EsdtBalance]] = [:],
        owner: String? = nil
    ) {
        self.addressData = address.toAddressData()
        self.balance = balance
        self.esdtBalances = Dictionary(uniqueKeysWithValues: esdtBalances.map { ($0.key.data(using: .utf8)!, $0.value) })
        self.owner = owner?.toAddressData() ?? nil
    }
    
    public func toAddress() -> Address {
        Address(buffer: MXBuffer(data: Array(self.addressData)))
    }
    
    public func getBalance() -> BigUint {
        return BigUint(bigEndianBuffer: MXBuffer(data: Array(self.balance.toBigEndianUnsignedData())))
    }

    public func getEsdtBalance(tokenIdentifier: String, nonce: UInt64) -> BigUint {
        guard let balances = self.esdtBalances[tokenIdentifier.data(using: .utf8)!] else {
            return 0
        }

        guard let balance = balances.first(where: { $0.nonce == nonce }) else {
            return 0
        }

        return BigUint(bigEndianBuffer: MXBuffer(data: Array(balance.balance.toBigEndianUnsignedData())))
    }
}

#endif
