import Space

struct StateModule {
    package static func addMultipleBoardMembers(newBoardMembers: Vector<Address>) -> UInt32 {
        let userMapper = StorageModule.userMapper
        
        newBoardMembers.forEach { newBoardMember in
            require(
                userMapper.getUserId(address: newBoardMember) == 0,
                "duplicate board member"
            )
            
            let newUserId = userMapper.getOrCreateUser(address: newBoardMember)
            
            StorageModule.userIdToRole[newUserId] = .boardMember
        }
        
        let numBoardMembersMapper = StorageModule.$numBoardMembers
        let newNumBoardMembers = numBoardMembersMapper.get() + UInt32(newBoardMembers.count)
        numBoardMembersMapper.set(newNumBoardMembers)
        
        return newNumBoardMembers
    }
    
    package static func getCallerIdAndRole() -> (UInt32, UserRole) {
        let caller = Message.caller
        let callerId = StorageModule.userMapper.getUserId(address: caller)
        let callerRole = StorageModule.userIdToRole[callerId]
        
        return (callerId, callerRole)
    }
    
    package static func getActionValidSignerCount(
        actionId: UInt32
    ) -> UInt32 {
        let signerIds = StorageModule.getActionSignerIdsMapper(actionId: actionId)
        
        var result: UInt32 = 0
        
        signerIds.forEach { signerId in
            let signerRole = StorageModule.userIdToRole[signerId]
            
            if signerRole.canSign() {
                result += 1
            }
        }
        
        return result
    }
    
    package static func getActionSigners(actionId: UInt32) -> Vector<Address> {
        let signerIdsMapper = StorageModule.getActionSignerIdsMapper(actionId: actionId)
        let userMapper = StorageModule.userMapper
        var signers: Vector<Address> = Vector()
        
        signerIdsMapper.forEach { signerId in
            signers = signers.appended(userMapper.getUserAddressUnchecked(id: signerId))
        }
        
        return signers
    }
    
    package static func getActionLastIndex() -> UInt32 {
        return StorageModule.getActionMapper().count
    }
    
    package static func getActionData(actionId: UInt32) -> Action {
        return StorageModule.getActionMapper().get(index: actionId)
    }

}
