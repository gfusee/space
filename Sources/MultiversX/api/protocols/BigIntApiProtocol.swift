protocol BigIntApiProtocol {
    func bigIntSetInt64Value(destination: Int32, value: Int64)
    func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32)
}
