//
//  Jess.swift
//  JessLang
//
//  Created by Andre jones on 1/22/26.
//

import Foundation

/*
 This file will act as the main manager of the language. Meaning it will use all of the helper functions
 */

class Jess {
    var hasError: Bool = false

    // Will report any error that the program has encountered
    func report(line: Int, message: String, location: String) {
        print("Error found at \(line). message: \(line).")
        hasError = true
    }
}
