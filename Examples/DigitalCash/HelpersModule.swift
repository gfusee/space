import MultiversX

struct HelpersModule {
    
    func getNumTokenTransfers(
        egldValue: BigUint,
        esdtTransfers: MXArray<TokenPayment>
    ) -> Int32 {
        var amount = esdtTransfers.count
        
        if egldValue > 0 {
            amount += 1
        }
        
        return amount
    }
    
    func getExpirationRound(valability: UInt64) -> UInt64 {
        let valabilityRounds = valability / SECONDS_PER_ROUND
        
        return Blockchain.getBlockRound() + valabilityRounds
    }
    
    func makeFunds(
        egldPayment: BigUint,
        esdtPayments: MXArray<TokenPayment>,
        address: Address,
        valability: UInt64
    ) {
        let depositMapper = StorageModule().$depositForDonor[address]
        
        var currentDeposit = depositMapper.get()
        
        require(
            currentDeposit.egldFunds == 0 && currentDeposit.esdtFunds.isEmpty,
            "key already used"
        )
        
        let numTokens = self.getNumTokenTransfers(
            egldValue: egldPayment,
            esdtTransfers: esdtPayments
        )
        
        currentDeposit.fees.numTokenToTransfer += UInt32(numTokens)
        currentDeposit.valability = valability
        currentDeposit.expirationRound = self.getExpirationRound(valability: valability)
        currentDeposit.esdtFunds = esdtPayments
        currentDeposit.egldFunds = egldPayment
    }
    
    func updateFees(
        callerAddress: Address,
        address: Address,
        payment: TokenPayment
    ) {
        let _ = self.getFeeForToken(token: payment.tokenIdentifier)
        let depositMapper = StorageModule().$depositForDonor[address]
        
        if !depositMapper.isEmpty() {
            var currentDeposit = depositMapper.get()
            
            require(
                currentDeposit.depositorAddress == callerAddress,
                "invalid depositor address"
            )
            
            require(
                currentDeposit.fees.value.tokenIdentifier == payment.tokenIdentifier,
                "can only have 1 type of token as fee"
            )
            
            currentDeposit.fees.value.amount = currentDeposit.fees.value.amount + payment.amount
            
            return
        }
        
        let newDeposit = DepositInfo(
            depositorAddress: callerAddress,
            esdtFunds: MXArray(),
            egldFunds: 0,
            valability: 0,
            expirationRound: 0,
            fees: Fee(numTokenToTransfer: 0, value: payment)
        )
        
        depositMapper.set(newDeposit)
    }
    
    func getFeeForToken(token: MXBuffer) -> BigUint {
        require(
            StorageModule().whitelistedFeeTokens.contains(value: token),
            "invalid fee token provided"
        )
        
        return StorageModule().feeForToken[token]
    }
    
}
