//
//  NKContext.swift
//  NativeWebKit
//
//  Created by Zack Qattan on 12/30/23.
//

import Foundation

enum NKContext {
    case app, safari
}

protocol HasNKContext {
    var context: NKContext { get }
}
