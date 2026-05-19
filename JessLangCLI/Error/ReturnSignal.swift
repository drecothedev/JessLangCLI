//
//  ReturnSignal.swift
//  JessLangCLI
//
//  Created by Andre jones on 2/17/26.
//

import Foundation

final class ReturnSignal: Error {
    let value: Any?
    init(_ value: Any?) {
        self.value = value
    }
}
