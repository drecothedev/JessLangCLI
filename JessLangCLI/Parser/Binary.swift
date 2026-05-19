//
//  Binary.swift
//  JessLang
//
//  Created by Andre jones on 1/31/26.
//

import Foundation

class Binary {
    let left: Expression
    let operation: Token
    let right: Expression
    
    init(left: Expression, operation: Token, right: Expression) {
        self.left = left
        self.operation = operation
        self.right = right
    }
}
