import SpaceKit

@Controller struct MyContract {
    @Mapping<Address, UInt64>(key: "storedIntegerForUser") var storedIntegerForUser
    
    public func increaseStoredValue() {
        
    }
}
