import Space

@Contract struct MyContract {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
}
