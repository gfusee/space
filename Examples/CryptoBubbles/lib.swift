import MultiversX

@Contract struct CryptoBubbles {
    
    @Mapping(key: "playerBalance") var playerBalance: StorageMap<Address, BigUint>
    
    public mutating func topUp() {
        let payment = Message.egldValue
        
        require(
            payment > 0,
            "Wrong payment"
        )
        
        let caller = Message.caller
        self.playerBalance[caller] = self.playerBalance[caller] + payment
    }
    
    mutating func transferBackToPlayerWallet(player: Address, amount: BigUint) {
        let playerBalance = self.playerBalance[player]
        
        require(
            amount <= playerBalance,
            "amount to withdraw must be less or equal to balance"
        )
        
        self.playerBalance[player] = playerBalance - amount
        
        player.send(egldValue: amount)
    }
    
    mutating func addPlayerToGameStateChange(
        gameIndex: BigUint,
        player: Address,
        bet: BigUint
    ) {
        let playerBalance = self.playerBalance[player]
        
        require(
            bet <= playerBalance,
            "insufficient funds to join game"
        )
        
        self.playerBalance[player] = self.playerBalance[player] - bet
    }
    
    public mutating func joinGame(
        gameIndex: BigUint
    ) {
        let bet = Message.egldValue
        
        require(
            bet > 0,
            "wrong payment"
        )
        
        let player = Message.caller
        
        self.topUp()
        self.addPlayerToGameStateChange(gameIndex: gameIndex, player: player, bet: bet)
    }
    
    public mutating func rewardWinner(
        gameIndex: BigUint,
        winner: Address,
        prize: BigUint
    ) {
        require( // TODO: add only owner wrapper
            Message.caller == Blockchain.getOwner(),
            "endpoint can only be called by owner"
        )
        
        self.playerBalance[winner] = self.playerBalance[winner] + prize
    }
    
    public mutating func rewardAndSendToWallet(
        gameIndex: BigUint,
        winner: Address,
        prize: BigUint
    ) {
        self.rewardWinner(gameIndex: gameIndex, winner: winner, prize: prize)
        self.transferBackToPlayerWallet(player: winner, amount: prize)
    }
    
    public func balanceOf(player: Address) -> BigUint {
        return self.playerBalance[player]
    }
}
