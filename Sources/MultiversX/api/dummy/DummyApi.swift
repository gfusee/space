#if !WASM
import Foundation
import BigInt

public class DummyApi {
    private var containerLock: NSLock = NSLock()
    package var globalLock: NSLock = NSLock()
    
    package var staticContainer = TransactionContainer(errorBehavior: .fatalError)
    package var transactionContainer: TransactionContainer? = nil
    
    package var blockInfos = BlockInfos(
        timestamp: 0
    )
    
    package var worldState = WorldState()
    
    package func runTransactions(transactionInput: TransactionInput, operations: @escaping () -> Void) throws(TransactionError) {
        self.containerLock.lock()
        
        while let transactionContainer = self.transactionContainer {
            if transactionContainer.error == nil {
                fatalError("A transaction is already ongoing. This error should never occur if you don't interact with the api directly.")
            }
        }
        
        self.transactionContainer = TransactionContainer(
            worldState: self.worldState,
            transactionInput: transactionInput,
            errorBehavior: .blockThread
        )

        defer {
            self.transactionContainer = nil
            self.containerLock.unlock()
        }

        if transactionInput.egldValue > 0 {
            guard transactionInput.esdtValue.isEmpty else {
                self.throwExecutionFailed(reason: "cannot have both egld and esdt value") // TODO: use the same error message as the SpaceVM
            }

            self.getCurrentContainer().performEgldTransfer(
                from: transactionInput.callerAddress,
                to: transactionInput.contractAddress,
                value: transactionInput.egldValue
            )
        } else {
            for value in transactionInput.esdtValue {
                self.getCurrentContainer().performEsdtTransfer(
                    from: transactionInput.callerAddress,
                    to: transactionInput.contractAddress,
                    token: value.tokenIdentifier,
                    nonce: value.nonce,
                    value: value.amount
                )
            }
        }
        
        var hasThreadStartedExecution = false
        
        let thread = Thread {
            hasThreadStartedExecution = true
            operations()
        }
        
        thread.start()
        
        while !hasThreadStartedExecution || thread.isExecuting {
            if let transactionContainer = self.transactionContainer {
                if transactionContainer.error != nil {
                    transactionContainer.shouldExitThread = true
                    break
                }
            }
        }
        
        let transactionContainer = self.transactionContainer! // It's impossible that this is nil
        
        if let transactionError = transactionContainer.error {
            throw transactionError
        } else {
            // Commit the container into the state
            self.worldState = transactionContainer.state
            self.transactionContainer = nil
        }
    }
    
    // TODO: If we are in a transaction context and another thread wants to perform operations on the static, it will modify instead the transaction container.
    
    package func getCurrentContainer() -> TransactionContainer {
        return self.transactionContainer ?? self.staticContainer
    }
    
    package func getAccount(addressData: Data) -> WorldAccount? {
        return self.worldState.getAccount(addressData: addressData)
    }
    
    package func setWorld(world: WorldState) {
        self.worldState = world
    }

    package func setCurrentSCOwnerAddress(owner: Data) {
        self.getCurrentContainer().setCurrentSCOwnerAddress(owner: owner)
    }
    
    func throwUserError(message: String) -> Never {
        self.getCurrentContainer().throwError(error: .userError(message: message))
    }
    
    func throwExecutionFailed(reason: String) -> Never {
        self.getCurrentContainer().throwError(error: .executionFailed(reason: reason))
    }
}

extension DummyApi: BufferApiProtocol {
    public func bufferSetBytes(handle: Int32, bytePtr: UnsafeRawPointer, byteLen: Int32) -> Int32 {
        let data = Data(bytes: bytePtr, count: Int(byteLen))
        self.getCurrentContainer().managedBuffersData[handle] = data
        
        return 0
    }
    
    public func mBufferSetByteSlice(
        mBufferHandle: Int32,
        startingPosition: Int32,
        dataLength: Int32,
        dataOffset: UnsafeRawPointer
    ) -> Int32 {
        var bufferData = self.getCurrentContainer().getBufferData(handle: mBufferHandle)
        let bufferDataCountBefore = bufferData.count
        
        let sliceData = Data(bytes: dataOffset, count: Int(dataLength))
        
        bufferData[Int(startingPosition)..<Int(startingPosition + dataLength)] = sliceData
        
        let bufferDataCountAfter = bufferData.count
        
        guard bufferDataCountBefore == bufferDataCountAfter else {
            self.throwExecutionFailed(reason: "Data's size after slice replacement is different than before it.")
        }
        
        self.getCurrentContainer().managedBuffersData[mBufferHandle] = bufferData
        
        return 0
    }
    
    public func mBufferAppendBytes(accumulatorHandle: Int32, byte_ptr: UnsafeRawPointer, byte_len: Int32) -> Int32 {
        fatalError()
    }
    
    public func bufferCopyByteSlice(
        sourceHandle: Int32,
        startingPosition: Int32,
        sliceLength: Int32,
        destinationHandle: Int32
    ) -> Int32 {
        let sourceData = self.getCurrentContainer().getBufferData(handle: sourceHandle)
        let endIndex = startingPosition + sliceLength
        
        guard sliceLength >= 0 else {
            throwUserError(message: "Negative slice length.")
        }
        
        guard startingPosition >= 0 else {
            throwUserError(message: "Negative start position.")
        }
        
        guard endIndex <= sourceData.count else {
            throwUserError(message: "Index out of range.")
        }
        
        let slice = sourceData[startingPosition..<endIndex]
        
        self.getCurrentContainer().managedBuffersData[destinationHandle] = slice
        
        return 0
    }

    public func bufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32 {
        let accumulatorData = self.getCurrentContainer().getBufferData(handle: accumulatorHandle)
        let data = self.getCurrentContainer().getBufferData(handle: dataHandle)
        
        self.getCurrentContainer().managedBuffersData[accumulatorHandle] = accumulatorData + data
        
        return 0
    }
    
    public func bufferGetLength(handle: Int32) -> Int32 {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        
        return Int32(data.count)
    }
    
    public func bufferGetBytes(handle: Int32, resultPointer: UnsafeRawPointer) -> Int32 {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        let unsafeBufferPointer = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(mutating: resultPointer), count: data.count)
        
        data.copyBytes(to: unsafeBufferPointer)
        
        return 0
    }

    public func bufferFinish(handle: Int32) -> Int32 {
        return 0
    }
    
    public func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bigInt = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        
        self.getCurrentContainer().managedBuffersData[bufferHandle] = bigInt.toBigEndianUnsignedData()
        
        return 0
    }
    
    public func bufferToBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bufferData = self.getCurrentContainer().getBufferData(handle: bufferHandle)
        let signData = "00".hexadecimal
        
        self.getCurrentContainer().managedBigIntData[bigIntHandle] = BigInt(signData + bufferData)
        
        return 0
    }
    
    public func bufferEqual(handle1: Int32, handle2: Int32) -> Int32 {
        let data1 = self.getCurrentContainer().getBufferData(handle: handle1)
        let data2 = self.getCurrentContainer().getBufferData(handle: handle2)
        
        return data1 == data2 ? 1 : 0
    }
    
    public func bufferToDebugString(handle: Int32) -> String {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        
        return data.hexEncodedString()
    }
    
    public func bufferToUTF8String(handle: Int32) -> String? {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        
        return String(data: data, encoding: .utf8)
    }
    
    public func managedBufferToHex(sourceHandle: Int32, destinationHandle: Int32) {
        // TODO: add tests for this opcode
        let sourceData = self.getCurrentContainer().getBufferData(handle: sourceHandle)
        let destinationData = sourceData.hexEncodedString().data(using: .utf8)
        
        self.getCurrentContainer().managedBuffersData[destinationHandle] = destinationData
    }
}

extension DummyApi: BigIntApiProtocol {
    public func bigIntSetInt64(destination: Int32, value: Int64) {
        self.getCurrentContainer().managedBigIntData[destination] = BigInt(integerLiteral: value)
    }
    
    public func bigIntIsInt64(reference: Int32) -> Int32 {
        let value = self.getCurrentContainer().getBigIntData(handle: reference)
        
        return value <= BigInt(Int64.max) ? 1 : 0
    }
    
    public func bigIntGetInt64Unsafe(reference: Int32) -> Int64 {
        let value = self.getCurrentContainer().getBigIntData(handle: reference)
        let formatted = String(value).replacingOccurrences(of: " ", with: "")
        
        return Int64(formatted)!
    }

    public func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        let bigIntValue = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        [UInt8](String(bigIntValue).data(using: .utf8)!).withUnsafeBytes { pointer in
            guard let baseAddress = pointer.baseAddress else {
                fatalError()
            }
            
            let _ = self.bufferSetBytes(handle: destHandle, bytePtr: baseAddress, byteLen: Int32(pointer.count))
        }
    }
    
    public func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32 {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        return lhs == rhs ? 0 : lhs > rhs ? 1 : -1
    }
    
    public func bigIntAdd(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        let result = lhs + rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntSub(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs > lhs {
            self.throwUserError(message: "Cannot substract because the result would be negative.")
        }
        
        let result = lhs - rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntMul(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        let result = lhs * rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntDiv(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.throwUserError(message: "Cannot divide by zero.")
        }
        
        let result = lhs / rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.throwUserError(message: "Cannot divide by zero (modulo).")
        }
        
        let result = lhs % rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntToString(bigIntHandle: Int32, destHandle: Int32) {
        let bigInt = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        let data = bigInt.description.data(using: .utf8)
        
        self.getCurrentContainer().managedBuffersData[destHandle] = data
    }
}

extension DummyApi: StorageApiProtocol {
    public func bufferStorageLoad(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        let keyData = self.getCurrentContainer().getBufferData(handle: keyHandle)
        let currentStorage = self.getCurrentContainer().getStorageForCurrentContractAddress()
        
        let valueData = currentStorage[keyData] ?? Data()
        
        self.getCurrentContainer().managedBuffersData[bufferHandle] = valueData
        
        return 0
    }
    
    public func bufferStorageStore(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        let keyData = self.getCurrentContainer().getBufferData(handle: keyHandle)
        let bufferData = self.getCurrentContainer().getBufferData(handle: bufferHandle)
        
        var currentStorage = self.getCurrentContainer().getStorageForCurrentContractAddress()
        currentStorage[keyData] = bufferData
        
        self.getCurrentContainer().setStorageForCurrentContractAddress(storage: currentStorage)
        
        return 0
    }
}

extension DummyApi: EndpointApiProtocol {
    public func getNumArguments() -> Int32 {
        return 0
    }
    
    func bufferGetArgument(argId: Int32, bufferHandle: Int32) -> Int32 {
        return 0
    }
}

extension DummyApi: BlockchainApiProtocol {
    public func managedSCAddress(resultHandle: Int32) {
        let currentContractAccount = self.getCurrentContainer().getCurrentSCAccount()
        
        self.getCurrentContainer().managedBuffersData[resultHandle] = currentContractAccount.addressData
    }
    
    public func getBlockTimestamp() -> Int64 {
        return self.blockInfos.timestamp
    }
    
    public func bigIntGetExternalBalance(addressPtr: UnsafeRawPointer, dest: Int32) {
        let addressData = Data(bytes: addressPtr, count: 32)
        
        guard let account = self.getAccount(addressData: addressData)
        else {
            self.getCurrentContainer().managedBigIntData[dest] = 0
            
            return
        }
        
        self.getCurrentContainer().managedBigIntData[dest] = account.balance
    }
    
    public func bigIntGetESDTExternalBalance(addressPtr: UnsafeRawPointer, tokenIDOffset: UnsafeRawPointer, tokenIDLen: Int32, nonce: Int64, dest: Int32) {
        let addressData = Data(bytes: addressPtr, count: 32)
        let tokenIdData = Data(bytes: tokenIDOffset, count: Int(tokenIDLen))
        
        guard let account = self.getAccount(addressData: addressData),
              let tokenBalances = account.esdtBalances[tokenIdData],
              let balance = tokenBalances.first(where: { $0.nonce == nonce })
        else {
            self.getCurrentContainer().managedBigIntData[dest] = 0
            
            return
        }
        
        self.getCurrentContainer().managedBigIntData[dest] = balance.balance
    }
    
    public func getCaller(resultOffset: UnsafeRawPointer) {
        let callerAccount = self.getCurrentContainer().getCurrentCallerAccount()
        let callerAccountAddressData = callerAccount.addressData
        
        let mutablePointer = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(mutating: resultOffset), count: callerAccountAddressData.count)
        
        callerAccountAddressData.copyBytes(to: mutablePointer)
    }

    public func managedOwnerAddress(resultHandle: Int32) {
        let ownerAccount = self.getCurrentContainer().getCurrentSCOwnerAccount()

        self.getCurrentContainer().managedBuffersData[resultHandle] = ownerAccount.addressData 
    }
    
    public func getGasLeft() -> Int64 {
        return 100 // TODO: the RustVM implements this the same way, in the future we should provide a real implementation
    }
}

extension DummyApi: CallValueApiProtocol {
    public func bigIntGetCallValue(dest: Int32) {
        let value = self.getCurrentContainer().getEgldValue()

        self.getCurrentContainer().managedBigIntData[dest] = value
    }

    public func managedGetMultiESDTCallValue(resultHandle: Int32) {
        let payments = self.getCurrentContainer().getEsdtValue()

        var array: MXArray<TokenPayment> = []
        for payment in payments {
            array = array.appended(
                TokenPayment.new(
                    tokenIdentifier: MXBuffer(data: Array(payment.tokenIdentifier)),
                    nonce: payment.nonce,
                    amount: BigUint(bigInt: payment.amount)
                )
            )
        }

        self.getCurrentContainer().managedBuffersData[resultHandle] = Data(array.buffer.toBytes())
    }
}

extension DummyApi: SendApiProtocol {
    public func managedMultiTransferESDTNFTExecute(
        dstHandle: Int32,
        tokenTransfersHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32 {
        // TODO: the current implementation doesn't care about sc-to-sc execution
        let sender = self.getCurrentContainer().getCurrentSCAccount()
        let receiver = self.getCurrentContainer().getBufferData(handle: dstHandle)
        
        var tokenTransfersBufferInput = BufferNestedDecodeInput(buffer: MXBuffer(handle: tokenTransfersHandle).clone())
        while tokenTransfersBufferInput.canDecodeMore() { // TODO: use managed vec once implemented
            let tokenPayment = TokenPayment(depDecode: &tokenTransfersBufferInput)
            let tokenIdentifier = self.getCurrentContainer().getBufferData(handle: tokenPayment.tokenIdentifier.handle)
            let value = self.getCurrentContainer().getBigIntData(handle: tokenPayment.amount.handle)
            
            if value > sender.balance {
                self.throwExecutionFailed(reason: "insufficient funds")
            }
            
            self.getCurrentContainer().performEsdtTransfer(from: sender.addressData, to: receiver, token: tokenIdentifier, nonce: tokenPayment.nonce, value: value)
        }
        
        return 0
    }
    
    public func managedTransferValueExecute(
        dstHandle: Int32,
        valueHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32 {
        // TODO: the current implementation doesn't care about sc-to-sc execution
        let sender = self.getCurrentContainer().getCurrentSCAccount()
        let value = self.getCurrentContainer().getBigIntData(handle: valueHandle)
        
        if value > sender.balance {
            self.throwExecutionFailed(reason: "insufficient funds")
        }
        
        let receiver = self.getCurrentContainer().getBufferData(handle: dstHandle)

        self.getCurrentContainer().performEgldTransfer(from: sender.addressData, to: receiver, value: value)
        
        return 0
    }
}

extension DummyApi: ErrorApiProtocol {
    public func managedSignalError(messageHandle: Int32) -> Never {
        let errorMessageData = self.getCurrentContainer().getBufferData(handle: messageHandle)
        self.throwUserError(message: String(data: errorMessageData, encoding: .utf8) ?? errorMessageData.hexEncodedString())
    }
}
#endif
