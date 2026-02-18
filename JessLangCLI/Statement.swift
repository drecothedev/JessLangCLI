//
//  Statement.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/16/26.
//

import Foundation

indirect enum Stmt {
    case expression(Expr)
    case print(Expr)
    case variable(name: Token, initializer: Expr?)
    case block([Stmt])
    case `if`(Expr, Stmt, Stmt?)
    case `while`(Expr, Stmt)

    case function(name: Token, params: [Token], body: [Stmt])
    case `return`(keyword: Token, value: Expr?)
}

