public struct BigUint {
    let handle: Int32
    
    public init() {
        self.init(value: getZeroedBytes8())
    }
    
    public init(value: Int64) {
        if value < 0 {
            smartContractError(message: "Cannot convert negative Int64 to BigUint.")
        }
        
        let handle = getNextHandle()
        API.bigIntSetInt64(destination: handle, value: value)
        self.handle = handle
    }
    
    public init(value: UInt64) {
        self.init(value: value.toBytes8())
    }
    
    public init(value: Int32) {
        if value < 0 {
            smartContractError(message: "Cannot convert negative Int32 to BigUint.")
        }
        
        self.init(value: value.toBytes8())
    }
    
    public init(value: UInt32) {
        self.init(value: value.toBytes8())
    }
    
    public init(value: UInt16) {
        self.init(value: value.toBytes8())
    }
    
    public init(value: UInt8) {
        self.init(value: value.toBytes8())
    }

    package init(value: Bytes8) {
        let buffer = Buffer(data: value)
        
        self = BigUint(bigEndianBuffer: buffer)
    }
    
    public init(bigEndianBuffer: Buffer) {
        let handle = getNextHandle()
        let _ = API.bufferToBigIntUnsigned(bufferHandle: bigEndianBuffer.handle, bigIntHandle: handle)
        
        self.handle = handle
    }
    
    init(handle: Int32) {
        self.handle = handle
    }

    public func toBuffer() -> Buffer {
        let destHandle = getNextHandle()
        API.bigIntToBuffer(bigIntHandle: self.handle, destHandle: destHandle)

        return Buffer(handle: destHandle)
    }
    
    public func toInt64() -> Int64? {
        return API.bigIntGetInt64(reference: self.handle)
    }
    
    func toBytesBigEndianBuffer() -> Buffer {
        let handle = getNextHandle()
        let _ = API.bufferFromBigIntUnsigned(bufferHandle: handle, bigIntHandle: self.handle)
        
        return Buffer(handle: handle)
    }
}

extension BigUint: Equatable {
    public static func == (lhs: BigUint, rhs: BigUint) -> Bool {
        return API.bigIntCompare(lhsHandle: lhs.handle, rhsHandle: rhs.handle) == 0
    }
}

extension BigUint {
    public static func == (left: BigUint, right: UInt8) -> Bool {
        left == BigUint(value: right)
    }
    
    public static func == (left: UInt8, right: BigUint) -> Bool {
        BigUint(value: left) == right
    }
    
    public static func == (left: BigUint, right: UInt16) -> Bool {
        left == BigUint(value: right)
    }
    
    public static func == (left: UInt16, right: BigUint) -> Bool {
        BigUint(value: left) == right
    }
    
    public static func == (left: BigUint, right: UInt32) -> Bool {
        left == BigUint(value: right)
    }
    
    public static func == (left: UInt32, right: BigUint) -> Bool {
        BigUint(value: left) == right
    }
    
    public static func == (left: BigUint, right: UInt64) -> Bool {
        left == BigUint(value: right)
    }
    
    public static func == (left: UInt64, right: BigUint) -> Bool {
        BigUint(value: left) == right
    }
    
    public static func == (left: BigUint, right: IntegerLiteralType) -> Bool {
        left == BigUint(value: Int64(right))
    }
    
    public static func == (left: IntegerLiteralType, right: BigUint) -> Bool {
        BigUint(value: Int64(left)) == right
    }
    
    public static func != (left: BigUint, right: UInt8) -> Bool {
        return left != BigUint(value: right)
    }

    public static func != (left: BigUint, right: UInt16) -> Bool {
        return left != BigUint(value: right)
    }

    public static func != (left: BigUint, right: UInt32) -> Bool {
        return left != BigUint(value: right)
    }

    public static func != (left: BigUint, right: UInt64) -> Bool {
        return left != BigUint(value: right)
    }

    public static func != (left: BigUint, right: IntegerLiteralType) -> Bool {
        return left != BigUint(value: Int64(right))
    }
    
    public static func + (left: BigUint, right: BigUint) -> BigUint {
        let handle = getNextHandle()
        API.bigIntAdd(destHandle: handle, lhsHandle: left.handle, rhsHandle: right.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func + (left: BigUint, right: UInt8) -> BigUint {
        left + BigUint(value: right)
    }
    
    public static func + (left: UInt8, right: BigUint) -> BigUint {
        BigUint(value: left) + right
    }
    
    public static func + (left: BigUint, right: UInt16) -> BigUint {
        left + BigUint(value: right)
    }
    
    public static func + (left: UInt16, right: BigUint) -> BigUint {
        BigUint(value: left) + right
    }
    
    public static func + (left: BigUint, right: UInt32) -> BigUint {
        left + BigUint(value: right)
    }
    
    public static func + (left: UInt32, right: BigUint) -> BigUint {
        BigUint(value: left) + right
    }
    
    public static func + (left: BigUint, right: UInt64) -> BigUint {
        left + BigUint(value: right)
    }
    
    public static func + (left: UInt64, right: BigUint) -> BigUint {
        BigUint(value: left) + right
    }
    
    public static func + (left: BigUint, right: IntegerLiteralType) -> BigUint {
        left + BigUint(value: Int64(right))
    }
    
    public static func + (left: IntegerLiteralType, right: BigUint) -> BigUint {
        BigUint(value: Int64(left)) + right
    }
    
    public static func += (left: inout BigUint, right: BigUint) {
        left = left + right
    }
    
    public static func += (left: inout BigUint, right: UInt8) {
        left = left + BigUint(value: right)
    }

    public static func += (left: inout BigUint, right: UInt16) {
        left = left + BigUint(value: right)
    }

    public static func += (left: inout BigUint, right: UInt32) {
        left = left + BigUint(value: right)
    }

    public static func += (left: inout BigUint, right: UInt64) {
        left = left + BigUint(value: right)
    }

    public static func += (left: inout BigUint, right: IntegerLiteralType) {
        left = left + BigUint(value: Int64(right))
    }
    
    public static func - (lhs: BigUint, rhs: BigUint) -> BigUint {
        guard lhs >= rhs else {
            smartContractError(message: Buffer(stringLiteral: BIG_UINT_SUB_NEGATIVE))
        }
        
        let handle = getNextHandle()
        API.bigIntSub(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func - (left: BigUint, right: UInt8) -> BigUint {
        left - BigUint(value: right)
    }
    
    public static func - (left: UInt8, right: BigUint) -> BigUint {
        BigUint(value: left) - right
    }
    
    public static func - (left: BigUint, right: UInt16) -> BigUint {
        left - BigUint(value: right)
    }
    
    public static func - (left: UInt16, right: BigUint) -> BigUint {
        BigUint(value: left) - right
    }
    
    public static func - (left: BigUint, right: UInt32) -> BigUint {
        left - BigUint(value: right)
    }
    
    public static func - (left: UInt32, right: BigUint) -> BigUint {
        BigUint(value: left) - right
    }
    
    public static func - (left: BigUint, right: UInt64) -> BigUint {
        left - BigUint(value: right)
    }
    
    public static func - (left: UInt64, right: BigUint) -> BigUint {
        BigUint(value: left) - right
    }
    
    public static func - (left: BigUint, right: IntegerLiteralType) -> BigUint {
        left - BigUint(value: Int64(right))
    }
    
    public static func - (left: IntegerLiteralType, right: BigUint) -> BigUint {
        BigUint(value: Int64(left)) - right
    }
    
    public static func -= (left: inout BigUint, right: BigUint) {
        left = left - right
    }
    
    public static func -= (left: inout BigUint, right: UInt8) {
        left = left - BigUint(value: right)
    }

    public static func -= (left: inout BigUint, right: UInt16) {
        left = left - BigUint(value: right)
    }

    public static func -= (left: inout BigUint, right: UInt32) {
        left = left - BigUint(value: right)
    }

    public static func -= (left: inout BigUint, right: UInt64) {
        left = left - BigUint(value: right)
    }

    public static func -= (left: inout BigUint, right: IntegerLiteralType) {
        left = left - BigUint(value: Int64(right))
    }
    
    public static func * (lhs: BigUint, rhs: BigUint) -> BigUint {
        let handle = getNextHandle()
        API.bigIntMul(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func * (left: BigUint, right: UInt8) -> BigUint {
        left * BigUint(value: right)
    }
    
    public static func * (left: UInt8, right: BigUint) -> BigUint {
        BigUint(value: left) * right
    }
    
    public static func * (left: BigUint, right: UInt16) -> BigUint {
        left * BigUint(value: right)
    }
    
    public static func * (left: UInt16, right: BigUint) -> BigUint {
        BigUint(value: left) * right
    }
    
    public static func * (left: BigUint, right: UInt32) -> BigUint {
        left * BigUint(value: right)
    }
    
    public static func * (left: UInt32, right: BigUint) -> BigUint {
        BigUint(value: left) * right
    }
    
    public static func * (left: BigUint, right: UInt64) -> BigUint {
        left * BigUint(value: right)
    }
    
    public static func * (left: UInt64, right: BigUint) -> BigUint {
        BigUint(value: left) * right
    }
    
    public static func * (left: BigUint, right: IntegerLiteralType) -> BigUint {
        left * BigUint(value: Int64(right))
    }
    
    public static func * (left: IntegerLiteralType, right: BigUint) -> BigUint {
        BigUint(value: Int64(left)) * right
    }
    
    public static func *= (left: inout BigUint, right: BigUint) {
        left = left * right
    }
    
    public static func *= (left: inout BigUint, right: UInt8) {
        left = left * BigUint(value: right)
    }

    public static func *= (left: inout BigUint, right: UInt16) {
        left = left * BigUint(value: right)
    }

    public static func *= (left: inout BigUint, right: UInt32) {
        left = left * BigUint(value: right)
    }

    public static func *= (left: inout BigUint, right: UInt64) {
        left = left * BigUint(value: right)
    }

    public static func *= (left: inout BigUint, right: IntegerLiteralType) {
        left = left * BigUint(value: Int64(right))
    }
    
    public static func / (lhs: BigUint, rhs: BigUint) -> BigUint {
        // TODO: be sure rhs == 0 throws an error on the SpaceVM (critical)
        let handle = getNextHandle()
        API.bigIntTDiv(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func / (left: BigUint, right: UInt8) -> BigUint {
        left / BigUint(value: right)
    }
    
    public static func / (left: UInt8, right: BigUint) -> BigUint {
        BigUint(value: left) / right
    }
    
    public static func / (left: BigUint, right: UInt16) -> BigUint {
        left / BigUint(value: right)
    }
    
    public static func / (left: UInt16, right: BigUint) -> BigUint {
        BigUint(value: left) / right
    }
    
    public static func / (left: BigUint, right: UInt32) -> BigUint {
        left / BigUint(value: right)
    }
    
    public static func / (left: UInt32, right: BigUint) -> BigUint {
        BigUint(value: left) / right
    }
    
    public static func / (left: BigUint, right: UInt64) -> BigUint {
        left / BigUint(value: right)
    }
    
    public static func / (left: UInt64, right: BigUint) -> BigUint {
        BigUint(value: left) / right
    }
    
    public static func / (left: BigUint, right: IntegerLiteralType) -> BigUint {
        left / BigUint(value: Int64(right))
    }
    
    public static func / (left: IntegerLiteralType, right: BigUint) -> BigUint {
        BigUint(value: Int64(left)) / right
    }
    
    public static func /= (left: inout BigUint, right: BigUint) {
        left = left / right
    }
    
    public static func /= (left: inout BigUint, right: UInt8) {
        left = left / BigUint(value: right)
    }

    public static func /= (left: inout BigUint, right: UInt16) {
        left = left / BigUint(value: right)
    }

    public static func /= (left: inout BigUint, right: UInt32) {
        left = left / BigUint(value: right)
    }

    public static func /= (left: inout BigUint, right: UInt64) {
        left = left / BigUint(value: right)
    }

    public static func /= (left: inout BigUint, right: IntegerLiteralType) {
        left = left / BigUint(value: Int64(right))
    }
    
    public static func % (lhs: BigUint, rhs: BigUint) -> BigUint {
        // TODO: be sure rhs == 0 throws an error on the SpaceVM (critical)
        let handle = getNextHandle()
        API.bigIntTMod(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func % (left: BigUint, right: UInt8) -> BigUint {
        left % BigUint(value: right)
    }
    
    public static func % (left: UInt8, right: BigUint) -> BigUint {
        BigUint(value: left) % right
    }
    
    public static func % (left: BigUint, right: UInt16) -> BigUint {
        left % BigUint(value: right)
    }
    
    public static func % (left: UInt16, right: BigUint) -> BigUint {
        BigUint(value: left) % right
    }
    
    public static func % (left: BigUint, right: UInt32) -> BigUint {
        left % BigUint(value: right)
    }
    
    public static func % (left: UInt32, right: BigUint) -> BigUint {
        BigUint(value: left) % right
    }
    
    public static func % (left: BigUint, right: UInt64) -> BigUint {
        left % BigUint(value: right)
    }
    
    public static func % (left: UInt64, right: BigUint) -> BigUint {
        BigUint(value: left) % right
    }
    
    public static func % (left: BigUint, right: IntegerLiteralType) -> BigUint {
        left % BigUint(value: Int64(right))
    }
    
    public static func % (left: IntegerLiteralType, right: BigUint) -> BigUint {
        BigUint(value: Int64(left)) % right
    }
    
    public static func %= (left: inout BigUint, right: BigUint) {
        left = left % right
    }
    
    public static func %= (left: inout BigUint, right: UInt8) {
        left = left % BigUint(value: right)
    }

    public static func %= (left: inout BigUint, right: UInt16) {
        left = left % BigUint(value: right)
    }

    public static func %= (left: inout BigUint, right: UInt32) {
        left = left % BigUint(value: right)
    }

    public static func %= (left: inout BigUint, right: UInt64) {
        left = left % BigUint(value: right)
    }

    public static func %= (left: inout BigUint, right: IntegerLiteralType) {
        left = left % BigUint(value: Int64(right))
    }

    
    public static func > (lhs: BigUint, rhs: BigUint) -> Bool {
        let compareResult = API.bigIntCompare(lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return compareResult == 1
    }
    
    public static func > (lhs: BigUint, rhs: UInt8) -> Bool {
        lhs > BigUint(value: rhs)
    }
    
    public static func > (lhs: UInt8, rhs: BigUint) -> Bool {
        BigUint(value: lhs) > rhs
    }
    
    public static func > (lhs: BigUint, rhs: UInt16) -> Bool {
        lhs > BigUint(value: rhs)
    }
    
    public static func > (lhs: UInt16, rhs: BigUint) -> Bool {
        BigUint(value: lhs) > rhs
    }
    
    public static func > (lhs: BigUint, rhs: UInt32) -> Bool {
        lhs > BigUint(value: rhs)
    }
    
    public static func > (lhs: UInt32, rhs: BigUint) -> Bool {
        BigUint(value: lhs) > rhs
    }
    
    public static func > (lhs: BigUint, rhs: UInt64) -> Bool {
        lhs > BigUint(value: rhs)
    }
    
    public static func > (lhs: UInt64, rhs: BigUint) -> Bool {
        BigUint(value: lhs) > rhs
    }
    
    public static func > (lhs: BigUint, rhs: IntegerLiteralType) -> Bool {
        lhs > BigUint(value: Int64(rhs))
    }
    
    public static func > (lhs: IntegerLiteralType, rhs: BigUint) -> Bool {
        BigUint(value: Int64(lhs)) > rhs
    }
    
    public static func <= (lhs: BigUint, rhs: BigUint) -> Bool {
        !(lhs > rhs)
    }
    
    public static func <= (lhs: BigUint, rhs: UInt8) -> Bool {
        lhs <= BigUint(value: rhs)
    }

    public static func <= (lhs: UInt8, rhs: BigUint) -> Bool {
        BigUint(value: lhs) <= rhs
    }

    public static func <= (lhs: BigUint, rhs: UInt16) -> Bool {
        lhs <= BigUint(value: rhs)
    }

    public static func <= (lhs: UInt16, rhs: BigUint) -> Bool {
        BigUint(value: lhs) <= rhs
    }

    public static func <= (lhs: BigUint, rhs: UInt32) -> Bool {
        lhs <= BigUint(value: rhs)
    }

    public static func <= (lhs: UInt32, rhs: BigUint) -> Bool {
        BigUint(value: lhs) <= rhs
    }

    public static func <= (lhs: BigUint, rhs: UInt64) -> Bool {
        lhs <= BigUint(value: rhs)
    }

    public static func <= (lhs: UInt64, rhs: BigUint) -> Bool {
        BigUint(value: lhs) <= rhs
    }

    public static func <= (lhs: BigUint, rhs: IntegerLiteralType) -> Bool {
        lhs <= BigUint(value: Int64(rhs))
    }

    public static func <= (lhs: IntegerLiteralType, rhs: BigUint) -> Bool {
        BigUint(value: Int64(lhs)) <= rhs
    }

    
    public static func < (lhs: BigUint, rhs: BigUint) -> Bool {
        lhs <= rhs && lhs != rhs
    }
    
    public static func < (lhs: BigUint, rhs: UInt8) -> Bool {
        lhs < BigUint(value: rhs)
    }

    public static func < (lhs: UInt8, rhs: BigUint) -> Bool {
        BigUint(value: lhs) < rhs
    }

    public static func < (lhs: BigUint, rhs: UInt16) -> Bool {
        lhs < BigUint(value: rhs)
    }

    public static func < (lhs: UInt16, rhs: BigUint) -> Bool {
        BigUint(value: lhs) < rhs
    }

    public static func < (lhs: BigUint, rhs: UInt32) -> Bool {
        lhs < BigUint(value: rhs)
    }

    public static func < (lhs: UInt32, rhs: BigUint) -> Bool {
        BigUint(value: lhs) < rhs
    }

    public static func < (lhs: BigUint, rhs: UInt64) -> Bool {
        lhs < BigUint(value: rhs)
    }

    public static func < (lhs: UInt64, rhs: BigUint) -> Bool {
        BigUint(value: lhs) < rhs
    }

    public static func < (lhs: BigUint, rhs: IntegerLiteralType) -> Bool {
        lhs < BigUint(value: Int64(rhs))
    }

    public static func < (lhs: IntegerLiteralType, rhs: BigUint) -> Bool {
        BigUint(value: Int64(lhs)) < rhs
    }
    
    public static func >= (lhs: BigUint, rhs: BigUint) -> Bool {
        lhs > rhs || lhs == rhs
    }
    
    public static func >= (lhs: BigUint, rhs: UInt8) -> Bool {
        lhs >= BigUint(value: rhs)
    }

    public static func >= (lhs: UInt8, rhs: BigUint) -> Bool {
        BigUint(value: lhs) >= rhs
    }

    public static func >= (lhs: BigUint, rhs: UInt16) -> Bool {
        lhs >= BigUint(value: rhs)
    }

    public static func >= (lhs: UInt16, rhs: BigUint) -> Bool {
        BigUint(value: lhs) >= rhs
    }

    public static func >= (lhs: BigUint, rhs: UInt32) -> Bool {
        lhs >= BigUint(value: rhs)
    }

    public static func >= (lhs: UInt32, rhs: BigUint) -> Bool {
        BigUint(value: lhs) >= rhs
    }

    public static func >= (lhs: BigUint, rhs: UInt64) -> Bool {
        lhs >= BigUint(value: rhs)
    }

    public static func >= (lhs: UInt64, rhs: BigUint) -> Bool {
        BigUint(value: lhs) >= rhs
    }

    public static func >= (lhs: BigUint, rhs: IntegerLiteralType) -> Bool {
        lhs >= BigUint(value: Int64(rhs))
    }

    public static func >= (lhs: IntegerLiteralType, rhs: BigUint) -> Bool {
        BigUint(value: Int64(lhs)) >= rhs
    }
}

extension BigUint: TopDecode {
    public init(topDecode input: Buffer) {
        self = Self(bigEndianBuffer: input)
    }
}

extension BigUint: TopDecodeMulti {}

extension BigUint: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = Buffer(depDecode: &input)
        
        self = Self(topDecode: buffer)
    }
}

extension BigUint: TopEncode {
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        output.setBuffer(buffer: self.toBytesBigEndianBuffer())
    }
}

extension BigUint: TopEncodeMulti {}

extension BigUint: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        self.toBytesBigEndianBuffer().depEncode(dest: &dest)
    }
}

extension BigUint: ArrayItem {
    public static var payloadSize: Int32 {
        return 4
    }
    
    public static func decodeArrayPayload(payload: Buffer) -> BigUint {
        var payloadInput = BufferNestedDecodeInput(buffer: payload)
        
        let handle = Int32(Int(depDecode: &payloadInput))
        
        guard !payloadInput.canDecodeMore() else {
            fatalError()
        }
        
        return BigUint(handle: handle)
    }
    
    public func intoArrayPayload() -> Buffer {
        return Buffer(data: self.handle.toBytes4())
    }
}

extension BigUint: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        #if WASM
        self.init(value: Int32(value).toBytes8())
        #else
        self.init(value: Int64(value).toBytes8())
        #endif
    }
}

#if !WASM
extension BigUint: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.stringDescription
    }
}

extension BigUint {
    public var stringDescription: String {
        let handle = getNextHandle()
        API.bigIntToString(bigIntHandle: self.handle, destHandle: handle)
        let utf8Buffer = Buffer(handle: handle)
        
        guard let utf8Description = utf8Buffer.utf8Description else {
            fatalError()
        }
        
        return utf8Description
    }
    
    public var hexDescription: String {
        self.toBytesBigEndianBuffer().hexDescription
    }
}
#endif
