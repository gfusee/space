public typealias MXString = MXBuffer

public struct MXBuffer {
    let handle: Int32
    
    public var count: Int {
        get {
            return Int(self.getCountSized())
        }
    }

    public init(_ string: StaticString) {
        let handle = getNextHandle()
        let _ = API.bufferSetBytes(handle: handle, bytePtr: string.utf8Start, byteLen: Int32(string.utf8CodeUnitCount))

        self.handle = handle
    }
    
    #if !WASM
    public init(_ string: String) {
        let handle = getNextHandle()
        
        [UInt8](string.utf8).withUnsafeBytes { pointer in
            guard let baseAddress = pointer.baseAddress else {
                fatalError()
            }
            
            let _ = API.bufferSetBytes(handle: handle, bytePtr: baseAddress, byteLen: Int32(pointer.count))
        }

        self.handle = handle
    }
    #endif

    public init() {
        self.init("")
    }

    public init(handle: Int32) {
        self.handle = handle
    }

    public mutating func append(_ other: Self) {
        let _ = API.bufferAppend(accumulatorHandle: self.handle, dataHandle: other.handle)
    }
    
    public func clone() -> MXBuffer {
        var result = MXBuffer()
        result.append(self)
        
        return result
    }
    
    #if !WASM
    func toBytes() -> [UInt8] {
        let selfCount = self.count
        let result: [UInt8] = Array(repeating: 0, count: selfCount)
        
        let _ = result.withUnsafeBytes { pointer in
            API.bufferGetBytes(handle: self.handle, resultPointer: pointer.baseAddress!)
        }
        
        return result
    }
    #endif
    
    func getCountSized() -> Int32 {
        return API.bufferGetLength(handle: self.handle)
    }

    public func finish() {
        let _ = API.bufferFinish(handle: self.handle)
    }
}

extension MXBuffer: TopEncodeOutput {
    public mutating func setBuffer(buffer: MXBuffer) {
        self = buffer
    }
}

extension MXBuffer: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        output.setBuffer(buffer: self)
    }
}

extension MXBuffer: Equatable {
    public static func == (lhs: MXBuffer, rhs: MXBuffer) -> Bool {
        return API.bufferEqual(handle1: lhs.handle, handle2: rhs.handle) > 0
    }
}

extension MXBuffer: ExpressibleByStringLiteral {
    public init(stringInterpolation: BufferInterpolationMatcher) {
        self.handle = stringInterpolation.buffer.handle
    }

    public init(stringLiteral value: StaticString) {
        self.init(value)
    }
}

public struct BufferInterpolationMatcher: StringInterpolationProtocol {
    var buffer: MXBuffer

    public init(literalCapacity: Int, interpolationCount: Int) {
        self.buffer = MXBuffer()
    }

    public mutating func appendLiteral(_ literal: StaticString) {
        self.buffer.append(MXBuffer(literal))
    }

    public mutating func appendInterpolation(_ value: MXBuffer) {
        self.buffer.append(value)
    }
    
    #if !WASM
    public mutating func appendInterpolation(_ value: String) {
        self.buffer.append(MXBuffer(value))
    }
    #endif
    
    public mutating func appendInterpolation(_ value: StaticString) {
        self.buffer.append(MXBuffer(value))
    }

    public mutating func appendInterpolation(_ value: BigUint) {
        self.buffer.append(value.toBuffer())
    }
}

extension MXBuffer: ExpressibleByStringInterpolation {}
