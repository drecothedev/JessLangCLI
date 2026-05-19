//
//  JessBuiltInFunctions.swift
//  JessLangCLI
//
//  Created by Andre jones on 3/11/26.
//

import Foundation

class JessBuiltInFunctions {
    let shared: JessBuiltInFunctions = JessBuiltInFunctions()
    
    func jessSqrt(_ num: Int) -> Double {
        return sqrt(Double(num))
    }
}
