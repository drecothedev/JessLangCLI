//
//  RuntimeError.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/15/26.
//

import Foundation

class RuntimeError: Error {
    final let token: Token
    final let message: String
    
    init(token: Token, message: String) {
        self.token = token
        self.message = message
    }
}
