//
//  ArrayUtils.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 1/29/24.
//

import Foundation

// https://stackoverflow.com/questions/55264145/simple-way-to-replace-an-item-in-an-array-if-it-exists-append-it-if-it-doesnt
extension Array {
    mutating func replaceOrAppend(_ item: Element, whereFirstIndex predicate: (Element) -> Bool) {
        if let idx = firstIndex(where: predicate) {
            self[idx] = item
        }
        else {
            append(item)
        }
    }

    mutating func replaceOrAppend<Value>(_ item: Element,
                                         firstMatchingKeyPath keyPath: KeyPath<Element, Value>)
        where Value: Equatable
    {
        let itemValue = item[keyPath: keyPath]
        self.replaceOrAppend(item, whereFirstIndex: { $0[keyPath: keyPath] == itemValue })
    }
}

extension Array where Element: Equatable {
    mutating func insertUnique(_ item: Element) {
        if !self.contains(where: { $0 == item }) {
            self.append(item)
        }
    }
}
