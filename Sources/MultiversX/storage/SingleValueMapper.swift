public var TEST_DEBUG: Bool = false // TODO: remove

public struct SingleValueMapper<V: TopEncode & TopDecode> {
    private let key: MXBuffer
    
    public init(key: MXBuffer) {
        self.key = key
    }

    public func clear() {
        // TODO: add tests
        clearStorage(key: self.key)
    }

    public func isEmpty() -> Bool {
        // TODO: add tests
        return self.getRawBuffer().count == 0
    }
    
    public func take() -> V {
        let value = self.get()
        self.clear()
        
        return value
    }
    
    private func getRawBuffer() -> MXBuffer {
        let storedValueBufferHandle = getNextHandle()
        let _ = API.bufferStorageLoad(keyHandle: self.key.handle, bufferHandle: storedValueBufferHandle)
        
        return MXBuffer(handle: storedValueBufferHandle)
    }
    
    public func get() -> V {
        if TEST_DEBUG {
            let test = self.getRawBuffer()
            smartContractError(message: test.toHexadecimalBuffer())
        }
        return V(topDecode: self.getRawBuffer())
    }
    
    public func set(_ newValue: V) {
        var output = MXBuffer()
        newValue.topEncode(output: &output)
        
        let _ = API.bufferStorageStore(keyHandle: self.key.handle, bufferHandle: output.handle)
    }
}
