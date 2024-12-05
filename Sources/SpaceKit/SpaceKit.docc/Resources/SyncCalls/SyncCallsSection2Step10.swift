import SpaceKit

@Proxy enum CalleeContractProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Controller struct MyContract {
    public func callDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
        
        CalleeContractProxy
            .deposit
            .callAndIgnoreResult(
                receiver: receiverAddress,
                egldValue: payment
            )
    }
    
    public func callWithdraw(
        receiverAddress: Address,
        amount: BigUint
    ) {
        let payment: TokenPayment = CalleeContractProxy
            .withdraw(amount: amount)
            .call(
                receiver: receiverAddress
            )
    }
}
