import SwiftSyntax

extension StructDeclSyntax {
    func isValidStruct() throws(CodableMacroError) {
        let members = self.memberBlock.members
        
        guard members.filter({ $0.decl.is(InitializerDeclSyntax.self) }).isEmpty else {
            throw CodableMacroError.noInitAllowed
        }
        
        guard !members.filter({ $0.decl.is(VariableDeclSyntax.self) }).isEmpty else {
            throw CodableMacroError.atLeastOneFieldRequired
        }
    }
}
