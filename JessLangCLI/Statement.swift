//
//  Statement.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/16/26.
//

import Foundation

enum Stmt {
    case expression(Expr)
    case print(Expr)
    case variable(name: Token, initializer: Expr?)
}
