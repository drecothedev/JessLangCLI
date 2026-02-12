//
//  main.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/2/26.
//

import Foundation


func main() {
    let expression: Expr = .binary(
        left: .unary(
            op: Token(type: .minus, lexeme: "-", literal: .none, line: 1),
            right: .literal(123)
        ),
        op: Token(type: .star, lexeme: "*", literal: .none, line: 1),
        right: .grouping(
            .literal(45.67)
        )
    )

    let printer = Expression(currentExpr: expression)
    print(printer.printExpr(expression))
    
    
    let expression2Token = Token(type: .minus, lexeme: "-", literal: .none, line: 2)
    let semiColon = Token(type: .semicolon, lexeme: ";", literal: .none, line: 3)
    let expression2: Expr = .unary(op: expression2Token, right: .literal(121))
    
    print(printer.printExpr(expression2))
    
    
    
    let parser = Parser(tokens: [expression2Token, semiColon])
    let expr = parser.parse() ?? Expr.literal("")
    
    print(printer.printExpr(expr))
}

main()



