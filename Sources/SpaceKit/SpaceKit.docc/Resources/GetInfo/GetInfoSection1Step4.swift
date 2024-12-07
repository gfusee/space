import SpaceKit

@Controller struct MyController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
    
    init(tokenIdentifier: Buffer) {
        self.tokenIdentifier = tokenIdentifier
    }
}
