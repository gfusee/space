import SpaceKit

@Proxy enum CalleeControllerProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Controller struct MyController {
    public func callDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
    }
}
