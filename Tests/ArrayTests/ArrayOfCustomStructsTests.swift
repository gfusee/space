@testable import MultiversX
import XCTest

@Codable struct CustomCodableStruct: Equatable {
    let firstElement: MXBuffer
    let secondElement: UInt64
    let thirdElement: UInt64
    let fourthElement: MXBuffer
}

@Contract struct ArrayOfCustomStructsTestsContract {
    
    public func testGetOutOfRangeShouldFail() {
        let array: MXArray<MXString> = ["Hello!", "Bonjour!", "¡Hola!"]
        
        let array2: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        ]
        
        _ = array[1]
    }
    
    public func testTopDecodeInputTooLarge() {
        let input = MXBuffer(data: Array("00000001610000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b2101".hexadecimal))
        
        _ = MXArray<CustomCodableStruct>(topDecode: input)
    }
    
    public func testReplacedOutOfRangeShouldFail() {
        let array: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        ]
        
        _ = array.replaced(
            at: 1,
            value: CustomCodableStruct(
                firstElement: "test1",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "test2"
            )
        )
    }
    
}

final class ArrayOfCustomStructsTests: ContractTestCase {
    
    func testEmptyArray() throws {
        let array: MXArray<CustomCodableStruct> = MXArray()
        
        let count = array.count
        
        XCTAssertEqual(count, 0)
        XCTAssertEqual(array.buffer.count, 0)
    }
    
    func testAppendedOneElementArray() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        
        let count = array.count
        let element = array.get(0)
        let expected = CustomCodableStruct(
            firstElement: "Hey!",
            secondElement: 10,
            thirdElement: 100,
            fourthElement: "How's it going?"
        )
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, expected)
        XCTAssertEqual(array.buffer.count, 24)
    }
    
    func testAppendedTwoElementsArray() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        )
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        
        let firstExpectedElement = CustomCodableStruct(
            firstElement: "Hey!",
            secondElement: 10,
            thirdElement: 100,
            fourthElement: "How's it going?"
        )
        
        let secondExpectedElement = CustomCodableStruct(
            firstElement: "test",
            secondElement: 30,
            thirdElement: 5,
            fourthElement: "test2"
        )
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, firstExpectedElement)
        XCTAssertEqual(secondElement, secondExpectedElement)
        XCTAssertEqual(array.buffer.count, 48)
    }
    
    func testTwoElementsArrayThroughLiteralAssign() throws {
        var array: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        
        let firstExpectedElement = CustomCodableStruct(
            firstElement: "Hey!",
            secondElement: 10,
            thirdElement: 100,
            fourthElement: "How's it going?"
        )
        
        let secondExpectedElement = CustomCodableStruct(
            firstElement: "test",
            secondElement: 30,
            thirdElement: 5,
            fourthElement: "test2"
        )
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, firstExpectedElement)
        XCTAssertEqual(secondElement, secondExpectedElement)
        XCTAssertEqual(array.buffer.count, 48)
    }
    
    func testAppendedContentsOf() throws {
        var array1: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        var array2: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "test3",
                secondElement: 1,
                thirdElement: 76,
                fourthElement: "test4"
            ),
            CustomCodableStruct(
                firstElement: "test5",
                secondElement: 80,
                thirdElement: 0,
                fourthElement: "test6"
            )
        ]
        
        let array = array1.appended(contentsOf: array2)
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            ),
            CustomCodableStruct(
                firstElement: "test3",
                secondElement: 1,
                thirdElement: 76,
                fourthElement: "test4"
            ),
            CustomCodableStruct(
                firstElement: "test5",
                secondElement: 80,
                thirdElement: 0,
                fourthElement: "test6"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testEquatableWhenEqual() throws {
        let array1: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        let array2: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        XCTAssertEqual(array1, array2)
    }
    
    func testEquatableWhenDifferentCount() throws {
        let array1: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        let array2: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        ]
        
        XCTAssertNotEqual(array1, array2)
    }
    
    func testEquatableWhenDifferentValues() throws {
        let array1: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        let array2: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 99,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        XCTAssertNotEqual(array1, array2)
    }
    
    func testPlusOperator() throws {
        func testAppendedContentsOf() throws {
            let array1: MXArray<CustomCodableStruct> = [
                CustomCodableStruct(
                    firstElement: "Hey!",
                    secondElement: 10,
                    thirdElement: 100,
                    fourthElement: "How's it going?"
                ),
                CustomCodableStruct(
                    firstElement: "test",
                    secondElement: 30,
                    thirdElement: 5,
                    fourthElement: "test2"
                )
            ]
            
            let array2: MXArray<CustomCodableStruct> = [
                CustomCodableStruct(
                    firstElement: "test3",
                    secondElement: 1,
                    thirdElement: 76,
                    fourthElement: "test4"
                ),
                CustomCodableStruct(
                    firstElement: "test5",
                    secondElement: 80,
                    thirdElement: 0,
                    fourthElement: "test6"
                )
            ]
            
            let array = array1 + array2
            let expected: MXArray<CustomCodableStruct> = [
                CustomCodableStruct(
                    firstElement: "Hey!",
                    secondElement: 10,
                    thirdElement: 100,
                    fourthElement: "How's it going?"
                ),
                CustomCodableStruct(
                    firstElement: "test",
                    secondElement: 30,
                    thirdElement: 5,
                    fourthElement: "test2"
                ),
                CustomCodableStruct(
                    firstElement: "test3",
                    secondElement: 1,
                    thirdElement: 76,
                    fourthElement: "test4"
                ),
                CustomCodableStruct(
                    firstElement: "test5",
                    secondElement: 80,
                    thirdElement: 0,
                    fourthElement: "test6"
                )
            ]
            
            XCTAssertEqual(array, expected)
        }
    }
    
    func testAppendedTwoElementsArrayThroughSubscript() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        )
        
        let count = array.count
        let firstElement = array[0]
        let secondElement = array[1]
        
        let firstExpectedElement = CustomCodableStruct(
            firstElement: "Hey!",
            secondElement: 10,
            thirdElement: 100,
            fourthElement: "How's it going?"
        )
        
        let secondExpectedElement = CustomCodableStruct(
            firstElement: "test",
            secondElement: 30,
            thirdElement: 5,
            fourthElement: "test2"
        )
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, firstExpectedElement)
        XCTAssertEqual(secondElement, secondExpectedElement)
        XCTAssertEqual(array.buffer.count, 48)
    }
    
    func testGetOutOfRangeShouldFail() throws {
        do {
            try ArrayOfBuffersTestsContract.testable("").testGetOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testForLoopZeroElement() throws {
        let array: MXArray<CustomCodableStruct> = MXArray()
        
        for _ in array {
            XCTFail()
        }
    }
    
    func testForLoopOneElement() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        
        for item in array {
            XCTAssertEqual(
                item,
                CustomCodableStruct(
                    firstElement: "Hey!",
                    secondElement: 10,
                    thirdElement: 100,
                    fourthElement: "How's it going?"
                )
            )
        }
    }
    
    func testForLoopTwoElements() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        )
        
        var heapArray: [CustomCodableStruct] = []
        
        for item in array {
            heapArray.append(item)
        }
        
        let expected: [CustomCodableStruct] = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        XCTAssertEqual(heapArray, expected)
    }
    
    func testTopEncodeZeroElement() throws {
        let array: MXArray<CustomCodableStruct> = MXArray()
        
        var output = MXBuffer()
        array.topEncode(output: &output)
        
        let expected: MXBuffer = ""
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeOneElement() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        
        var output = MXBuffer()
        array.topEncode(output: &output)
        
        let expected = MXBuffer(data: Array("0000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeTwoElements() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        )
        
        var output = MXBuffer()
        array.topEncode(output: &output)
        
        let expected = MXBuffer(data: Array("0000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f0000000474657374000000000000001e0000000000000005000000057465737432".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeZeroElement() throws {
        let array: MXArray<CustomCodableStruct> = MXArray()
        
        var output = MXBuffer()
        array.depEncode(dest: &output)
        
        let expected = MXBuffer(data: Array("00000000".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeOneElement() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        
        var output = MXBuffer()
        array.depEncode(dest: &output)
        
        let expected = MXBuffer(data: Array("000000010000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeTwoElements() throws {
        var array: MXArray<CustomCodableStruct> = MXArray()
        array = array.appended(
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        )
        
        var output = MXBuffer()
        array.depEncode(dest: &output)
        
        let expected = MXBuffer(data: Array("000000020000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f0000000474657374000000000000001e0000000000000005000000057465737432".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopDecodeZeroElement() throws {
        let input = MXBuffer(data: Array("".hexadecimal))
        
        let array = MXArray<CustomCodableStruct>(topDecode: input)
        let expected: MXArray<CustomCodableStruct> = []
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeOneElement() throws {
        let input = MXBuffer(data: Array("0000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f".hexadecimal))
        
        let array = MXArray<CustomCodableStruct>(topDecode: input)
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeTwoElements() throws {
        let input = MXBuffer(data: Array("0000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f0000000474657374000000000000001e0000000000000005000000057465737432".hexadecimal))
        
        let array = MXArray<CustomCodableStruct>(topDecode: input)
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeZeroElement() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000".hexadecimal)))
        
        let array = MXArray<CustomCodableStruct>.depDecode(input: &input)
        let expected: MXArray<CustomCodableStruct> = []
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeOneElement() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000000010000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f".hexadecimal)))
        
        let array = MXArray<CustomCodableStruct>.depDecode(input: &input)
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeTwoElements() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000000020000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f0000000474657374000000000000001e0000000000000005000000057465737432".hexadecimal)))
        
        let array = MXArray<CustomCodableStruct>.depDecode(input: &input)
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeTwoElementsAndInputLarger() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000000020000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f0000000474657374000000000000001e000000000000000500000005746573743201".hexadecimal)))
        
        let array = MXArray<CustomCodableStruct>.depDecode(input: &input)
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            )
        ]
        
        XCTAssertEqual(array, expected)
        XCTAssertEqual(input.canDecodeMore(), true)
    }
    
    func testReplaceFirstElement() throws {
        let array: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            ),
            CustomCodableStruct(
                firstElement: "test3",
                secondElement: 1,
                thirdElement: 76,
                fourthElement: "test4"
            )
        ]
        
        let replaced = array.replaced(
            at: 0,
            value: CustomCodableStruct(
                firstElement: "replaced value 1",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "replaced value 2"
            )
        )
        
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "replaced value 1",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "replaced value 2"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            ),
            CustomCodableStruct(
                firstElement: "test3",
                secondElement: 1,
                thirdElement: 76,
                fourthElement: "test4"
            )
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplaceSecondElement() throws {
        let array: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            ),
            CustomCodableStruct(
                firstElement: "test3",
                secondElement: 1,
                thirdElement: 76,
                fourthElement: "test4"
            )
        ]
        
        let replaced = array.replaced(
            at: 1,
            value: CustomCodableStruct(
                firstElement: "replaced value 1",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "replaced value 2"
            )
        )
        
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "replaced value 1",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "replaced value 2"
            ),
            CustomCodableStruct(
                firstElement: "test3",
                secondElement: 1,
                thirdElement: 76,
                fourthElement: "test4"
            )
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplaceThirdElement() throws {
        let array: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            ),
            CustomCodableStruct(
                firstElement: "test3",
                secondElement: 1,
                thirdElement: 76,
                fourthElement: "test4"
            )
        ]
        
        let replaced = array.replaced(
            at: 2,
            value: CustomCodableStruct(
                firstElement: "replaced value 1",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "replaced value 2"
            )
        )
        
        let expected: MXArray<CustomCodableStruct> = [
            CustomCodableStruct(
                firstElement: "Hey!",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "How's it going?"
            ),
            CustomCodableStruct(
                firstElement: "test",
                secondElement: 30,
                thirdElement: 5,
                fourthElement: "test2"
            ),
            CustomCodableStruct(
                firstElement: "replaced value 1",
                secondElement: 10,
                thirdElement: 100,
                fourthElement: "replaced value 2"
            )
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplacedOutOfRangeShouldFail() throws {
        do {
            try ArrayOfBuffersTestsContract.testable("").testReplacedOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
}