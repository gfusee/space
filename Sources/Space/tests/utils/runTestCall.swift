#if !WASM
import Foundation
import BigInt

public func runTestCall<each InputArg: TopEncode & NestedEncode & NestedDecode, ReturnType: TopEncode & TopDecode>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    transactionInput: TransactionInput,
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping (repeat each InputArg) -> ReturnType
) throws(TransactionError) -> ReturnType {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsArray: Vector<Buffer> = Vector()
    var concatenatedInputArgsBuffer =  Buffer() // We don't want the same encoding as Vector, since we will dep decode multiple types, the same way as a struct
    for value in repeat each args {
        var argTopEncodedBuffer = Buffer()
        var argNestedEncodedBuffer = Buffer()
        value.topEncode(output: &argTopEncodedBuffer)
        value.depEncode(dest: &argNestedEncodedBuffer)
        
        concatenatedInputArgsArray = concatenatedInputArgsArray.appended(argTopEncodedBuffer)
        concatenatedInputArgsBuffer = concatenatedInputArgsBuffer + argNestedEncodedBuffer
    }
    
    var concatenatedInputArgsTopEncoded = Buffer()
    concatenatedInputArgsArray.topEncode(output: &concatenatedInputArgsTopEncoded)
    
    let concatenatedInputArgsBufferBytes = concatenatedInputArgsBuffer.toBytes()
    
    var bytesData: [UInt8] = []
    
    try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput,
        operations: UncheckedClosure {
            var injectedInputBuffer = BufferNestedDecodeInput(buffer: Buffer(data: concatenatedInputArgsBufferBytes))
            
            let result = operation(repeat (each InputArg)(depDecode: &injectedInputBuffer))
            
            var bytesDataBuffer = Buffer()
            result.topEncode(output: &bytesDataBuffer)
            bytesData = bytesDataBuffer.toBytes() // We have to extract the bytes from the transaction context...
        }
    )
    
    let extractedResultBuffer = Buffer(data: bytesData) // ...and reinject it in the root context
    let extractedResult = ReturnType(topDecode: extractedResultBuffer)
    
    return extractedResult
}

public func runTestCall<each InputArg: TopEncode & NestedEncode & NestedDecode>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    transactionInput: TransactionInput,
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping (repeat each InputArg) -> Void
) throws(TransactionError) {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsArray: Vector<Buffer> = Vector()
    var concatenatedInputArgsBuffer =  Buffer() // We don't want the same encoding as Vector, since we will dep decode multiple types, the same way as a struct
    for value in repeat each args {
        var argTopEncodedBuffer = Buffer()
        var argNestedEncodedBuffer = Buffer()
        value.topEncode(output: &argTopEncodedBuffer)
        value.depEncode(dest: &argNestedEncodedBuffer)
        
        concatenatedInputArgsArray = concatenatedInputArgsArray.appended(argTopEncodedBuffer)
        concatenatedInputArgsBuffer = concatenatedInputArgsBuffer + argNestedEncodedBuffer
    }
    
    var concatenatedInputArgsTopEncoded = Buffer()
    concatenatedInputArgsArray.topEncode(output: &concatenatedInputArgsTopEncoded)
    
    let concatenatedInputArgsBufferBytes = concatenatedInputArgsBuffer.toBytes()
    
    try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput,
        operations: UncheckedClosure {
            var injectedInputBuffer = BufferNestedDecodeInput(buffer: Buffer(data: concatenatedInputArgsBufferBytes))
            
            operation(repeat (each InputArg)(depDecode: &injectedInputBuffer))
        }
    )
}


#endif
