import Space

fileprivate let PERFORM_ACTION_FINISH_GAS: UInt64 = 500_000
fileprivate let PERFORM_ASYNC_CALL_ACTION_FINISH_GAS: UInt64 = 15_000_000
fileprivate let PERFORM_ASYNC_CALLBACK_GAS: UInt64 = 1_000_000

fileprivate func addSignedInt32ToUnsignedInt32(value: UInt32, delta: Int32) -> UInt32 {
    return if delta == 0 {
        value
    } else if delta > 0 {
        value + UInt32(delta)
    } else {
        value - UInt32(-delta)
    }
}

struct PerformModule {
    package static func getGasForTransferExec() -> UInt64 {
        let gasLeft = Blockchain.getGasLeft()
        
        if gasLeft <= PERFORM_ACTION_FINISH_GAS {
            smartContractError(message: "insufficient gas for call")
        }
        
        return gasLeft - PERFORM_ACTION_FINISH_GAS
    }
    
    package static func getGasForAsyncCall() -> UInt64 {
        let gasLeft = Blockchain.getGasLeft()
        
        let gasToKeep = PERFORM_ASYNC_CALL_ACTION_FINISH_GAS + PERFORM_ASYNC_CALLBACK_GAS
        
        if gasLeft <= gasToKeep {
            smartContractError(message: "insufficient gas for async call")
        }
        
        return gasLeft - gasToKeep
    }
    
    package static func changeUserRole(
        actionId: UInt32,
        userAddress: Address,
        newRole: UserRole
    ) {
        let userMapper = StorageModule.userMapper
        
        let userId: UInt32
        if newRole == .none {
            // avoid creating a new user just to delete it
            userId = userMapper.getUserId(address: userAddress)
            
            if userId == 0 {
                return
            }
        } else {
            userId = userMapper.getOrCreateUser(address: userAddress)
        }
        
        let userIdToRoleMapper = StorageModule.$userIdToRole[userId]
        let oldRole = userIdToRoleMapper.get()
        userIdToRoleMapper.set(newRole)
        
        PerformChangeUser(
            actionId: actionId,
            changedUser: userAddress,
            oldRole: oldRole,
            newRole: newRole
        ).emit()
        
        // update board size
        var boardMembersDelta: Int32 = 0
        if oldRole == .boardMember {
            boardMembersDelta -= 1
        }
        if newRole == .boardMember {
            boardMembersDelta += 1
        }
        
        if boardMembersDelta != 0 {
            let numBoardMembersMapper = StorageModule.$numBoardMembers
            
            var numBoardMembers = numBoardMembersMapper.get()
            numBoardMembers = addSignedInt32ToUnsignedInt32(value: numBoardMembers, delta: boardMembersDelta)
            
            numBoardMembersMapper.set(numBoardMembers)
        }
        
        var proposerDelta: Int32 = 0
        if oldRole == .proposer {
            proposerDelta -= 1
        }
        if newRole == .proposer {
            proposerDelta += 1
        }
        
        if proposerDelta != 0 {
            let numProposerMapper = StorageModule.$numProposers
            
            var numProposer = numProposerMapper.get()
            numProposer = addSignedInt32ToUnsignedInt32(value: numProposer, delta: proposerDelta)
            
            numProposerMapper.set(numProposer)
        }
    }
    
    package static func clearAction(actionId: UInt32) {
        StorageModule.getActionMapper().clearEntryUnchecked(index: actionId)
        StorageModule.getActionSignerIdsMapper(actionId: actionId).clear()
    }
    
    package static func performAction(actionId: UInt32) -> OptionalArgument<Address> {
        let action = StorageModule.getActionMapper().get(index: actionId)
        
        StartPerformAction()
            .emit(data: ActionFullInfo(
                actionId: actionId,
                actionData: action,
                signers: StateModule.getActionSigners(actionId: actionId)
            )
        )
        
        PerformModule.clearAction(actionId: actionId)
        
        let result: OptionalArgument<Address>
        switch action {
        case .nothing:
            result = .none
        case .addBoardMember(let boardMemberAddress):
            self.changeUserRole(actionId: actionId, userAddress: boardMemberAddress, newRole: .boardMember)
            result = .none
        case .addProposer(let proposerAddress):
            self.changeUserRole(actionId: actionId, userAddress: proposerAddress, newRole: .proposer)
            
            // validation required for the scenario when a board member becomes a proposer
            require(
                StorageModule.quorum <= StorageModule.numBoardMembers,
                "quorum cannot exceed board size"
            )
            
            result = .none
        case .removeUser(let userAddress):
            self.changeUserRole(actionId: actionId, userAddress: userAddress, newRole: .none)
            let numBoardMembers = StorageModule.numBoardMembers
            let numProposer = StorageModule.numProposers
            
            require(
                numBoardMembers + numProposer > 0,
                "cannot remove all board members and proposers"
            )
            require(
                StorageModule.quorum <= numBoardMembers,
                "quorum cannot exceed board size"
            )
            
            result = .none
        case .changeQuorum(let newQuorum):
            require(
                newQuorum <= StorageModule.numBoardMembers,
                "quorum cannot exceed board size"
            )
            
            StorageModule.quorum = newQuorum
            
            PerformChangeQuorum(
                actionId: actionId,
                newQuorum: newQuorum
            ).emit()
            
            result = .none
        case .sendTransferExecute(let callData):
            let gas = PerformModule.getGasForTransferExec()
            
            PerformTransferExecute(
                actionId: actionId,
                to: callData.to,
                egldValue: callData.egldAmount,
                gas: gas,
                endpoint: callData.endpointName,
                arguments: MultiValueEncoded(rawBuffers: callData.arguments)
            ).emit()
            
            ContractCall(
                receiver: callData.to,
                endpointName: callData.endpointName,
                argBuffer: callData.arguments.toArgBuffer()
            )
            .transferExecute(
                gas: gas,
                value: callData.egldAmount
            )
            
            result = .none
        case .sendAsyncCall(let callData):
            let gas = PerformModule.getGasForAsyncCall()
            
            PerformAsyncCall(
                actionId: actionId,
                to: callData.to,
                egldValue: callData.egldAmount,
                gas: gas,
                endpoint: callData.endpointName,
                arguments: MultiValueEncoded(rawBuffers: callData.arguments)
            ).emit()
            
            ContractCall(
                receiver: callData.to,
                endpointName: callData.endpointName,
                argBuffer: callData.arguments.toArgBuffer()
            )
            .registerPromise(
                callbackName: "performAsyncCallCallback",
                gas: gas,
                gasForCallback: PERFORM_ASYNC_CALLBACK_GAS,
                callbackArgs: ArgBuffer(),
                value: callData.egldAmount
            )
            
            result = .none
        case .scDeployFromSource(let deployData):
            let gas = Blockchain.getGasLeft()
            
            PerformDeployFromSource(
                actionId: actionId,
                egldValue: deployData.amount,
                sourceAddress: deployData.source,
                codeMetadata: deployData.codeMetadata,
                gas: gas,
                arguments: MultiValueEncoded(rawBuffers: deployData.arguments)
            ).emit()
            
            let (newAddress, _) = Blockchain.deploySCFromSource(
                gas: gas,
                sourceAddress: deployData.source,
                codeMetadata: deployData.codeMetadata,
                value: deployData.amount,
                arguments: ArgBuffer(rawArgs: deployData.arguments)
            )
            
            result = .some(newAddress)
        case .scUpgradeFromSource(let upgradeData):
            let gas = Blockchain.getGasLeft()
            
            PerformUpgradeFromSource(
                actionId: actionId,
                targetAddress: upgradeData.scAddress,
                egldValue: upgradeData.amount,
                sourceAddress: upgradeData.source,
                codeMetadata: upgradeData.codeMetadata,
                gas: gas,
                arguments: MultiValueEncoded(rawBuffers: upgradeData.arguments)
            ).emit()
            
            let _ = Blockchain.upgradeSCFromSource(
                contractAddress: upgradeData.scAddress,
                gas: gas,
                sourceAddress: upgradeData.source,
                codeMetadata: upgradeData.codeMetadata,
                value: upgradeData.amount,
                arguments: ArgBuffer(rawArgs: upgradeData.arguments)
            )
            
            result = .none
        }
        
        return result
    }
    
    package static func performAsyncCallCallback() {
        let result: AsyncCallResult<MultiValueEncoded<Buffer>> = Message.asyncCallResult()
        
        switch result {
        case .success(let data):
            AsyncCallSuccess(results: data)
                .emit()
        case .error(let error):
            AsyncCallError(
                errorCode: error.errorCode,
                errorMessage: error.errorMessage
            ).emit()
        }
    }
    
    package static func quorumReached(actionId: UInt32) -> Bool {
        let quorum = StorageModule.quorum
        let validSignersCount = StateModule.getActionValidSignerCount(actionId: actionId)
        
        return validSignersCount >= quorum
    }
}
