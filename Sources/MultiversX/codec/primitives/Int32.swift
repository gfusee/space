private let intSize: Int32 = 4

extension Int32 {
    // This function should be inlined top avoid heap allocation
    @inline(__always) package func asBigEndianBytes() -> Bytes4 {
        return (
            UInt8((self >> 24) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF)
        )
    }
}

extension Int32: TopEncode {
    @inline(__always)
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = self.asBigEndianBytes()
        var bigEndianBytesArray = FixedArray8<UInt8>(count: Int(intSize))
        
        bigEndianBytesArray[0] = bigEndianBytes.0
        bigEndianBytesArray[1] = bigEndianBytes.1
        bigEndianBytesArray[2] = bigEndianBytes.2
        bigEndianBytesArray[3] = bigEndianBytes.3
        
        let leftBytesToRemove = self >= 0 ? 0x00 : 0xFF
        
        var startEncodingIndex: Int32 = 0
        while startEncodingIndex < intSize && bigEndianBytesArray[Int(startEncodingIndex)] == leftBytesToRemove {
            startEncodingIndex += 1
        }
        
        MXBuffer(data: bigEndianBytes)
            .getSubBuffer(startIndex: startEncodingIndex, length: intSize - startEncodingIndex)
            .topEncode(output: &output)
    }
}

extension Int32: TopEncodeMulti {}

extension Int32: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: self.asBigEndianBytes()))
    }
}

extension Int32: TopDecode {
    public init(topDecode input: MXBuffer) {
        let bytes: FixedArray8<UInt8> = input.toFixedSizeBytes()
        if bytes.count > intSize {
            smartContractError(message: "Cannot decode Int: input too large.")
        }
        
        self = bytes.toBigEndianInt()
    }
}

extension Int32: TopDecodeMulti {}

extension Int32: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = input.readNextBuffer(length: intSize)
        
        self = Int32(topDecode: buffer)
    }
}
