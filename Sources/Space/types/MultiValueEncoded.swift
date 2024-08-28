// TODO: add tests

public struct MultiValueEncoded<Item: MXCodable> {
    private var rawBuffers: Vector<Buffer>
    
    public var count: Int32 {
        self.rawBuffers.count
    }
    
    public init() {
        self.rawBuffers = Vector()
    }
    
    // unsafe
    package init(rawBuffers: Vector<Buffer>) {
        self.rawBuffers = rawBuffers
    }
    
    public init(items: Vector<Item>) {
        var result: MultiValueEncoded<Item> = MultiValueEncoded()
        
        items.forEach { item in
            result = result.appended(value: item)
        }
        
        self = result
    }
    
    public func appended(value: Item) -> MultiValueEncoded<Item> {
        var newRawBuffers = self.rawBuffers.clone()
        
        value.multiEncode(output: &newRawBuffers)
        
        return MultiValueEncoded(rawBuffers: newRawBuffers)
    }
    
    public func get(_ index: Int32) -> Item {
        return Item(topDecode: self.rawBuffers.get(index))
    }
    
    public func toArray() -> Vector<Item> {
        var result = Vector<Item>()
        
        self.forEach { result = result.appended($0) }
        
        return result
    }
}

extension MultiValueEncoded: MXSequence {
    public func forEach(_ operations: (Item) throws -> Void) rethrows {
        let count = self.count
        var index: Int32 = 0
        
        while index < count {
            let element = self.get(index)
            try operations(element)
            
            index += 1
        }
    }
}

extension MultiValueEncoded: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        self.rawBuffers.forEach { $0.multiEncode(output: &output) }
    }
}

extension MultiValueEncoded: TopDecodeMulti {
    public init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        var rawBuffersField: Vector<Buffer> = Vector()
        
        while input.hasNext() {
            rawBuffersField = rawBuffersField.appended(input.nextValueInput())
        }
        
        self = MultiValueEncoded(rawBuffers: rawBuffersField)
    }
}
