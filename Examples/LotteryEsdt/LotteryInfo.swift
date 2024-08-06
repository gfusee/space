import MultiversX

// TODO: use TokenIdentifier type
@Codable struct LotteryInfo {
    let tokenIdentifier: MXBuffer
    let ticketPrice: BigUint
    var ticketsLeft: UInt32
    let deadline: UInt64
    let maxEntriesPerUser: UInt32
    let prizeDistribution: MXArray<UInt8>
    var prizePool: BigUint
}
