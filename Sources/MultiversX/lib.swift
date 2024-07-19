#if WASM
var API = VMApi()
#else
public var API = DummyApi()
#endif

@attached(peer)
@attached(member, names: arbitrary)
public macro Contract() = #externalMacro(module: "ContractMacro", type: "Contract")

@attached(extension, conformances: TopEncode & TopDecode & TopDecodeMulti & NestedEncode & NestedDecode & ArrayItem, names: arbitrary)
public macro Codable() = #externalMacro(module: "CodableMacro", type: "Codable")

@attached(extension, conformances: TopEncode & TopDecode & TopDecodeMulti & NestedEncode & NestedDecode & ArrayItem, names: arbitrary)
public macro Event(dataType: TopEncode.Type) = #externalMacro(module: "EventMacro", type: "Event")

var nextHandle: Int32 = -100
func getNextHandle() -> Int32 {
    let currentHandle = nextHandle
    nextHandle -= 1

    return currentHandle
}
