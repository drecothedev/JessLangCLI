//
//  StackDS.swift
//  JessLang
//
//  Created by Andre jones on 1/22/26.
//

import Foundation

struct Stack<Item> {
    var items: [Item]
    
    mutating func append(_ newVal: Item) {
        items.append(newVal)
    }
    
    mutating func pop() -> Item {
        guard !items.isEmpty else { fatalError("Stack is empty. Please add to it before trying to remove.") }
        return items.removeLast()
    }
}
