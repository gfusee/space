import CryptoKittiesRandom
import Space

@Codable public struct KittyGenes {
    public let furColor: Color
    public let eyeColor: Color
    public let meowPower: UInt8
    
    // TODO: remove this helper when @Codable exposes the default init as public
    public static func new(
        furColor: Color,
        eyeColor: Color,
        meowPower: UInt8
    ) -> KittyGenes {
        return KittyGenes(
            furColor: furColor,
            eyeColor: eyeColor,
            meowPower: meowPower
        )
    }
    
    public static func getDefault() -> KittyGenes {
        return KittyGenes(
            furColor: Color.getDefault(),
            eyeColor: Color.getDefault(),
            meowPower: 0
        )
    }
    
    public static func getRandom(random: inout Random) -> KittyGenes {
        return KittyGenes(
            furColor: Color.getRandom(random: &random),
            eyeColor: Color.getRandom(random: &random),
            meowPower: random.nextU8()
        )
    }
    
    public func intoUInt64() -> UInt64 {
        (self.furColor.intoUInt64() << 12 | self.eyeColor.intoUInt64()) << 4 | UInt64(self.meowPower).bigEndian
    }
}
