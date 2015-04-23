//
//  Swipe.swift
//  Cookie Crunch
//
//  Created by Adam on 4/20/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import Foundation

// Swap is a struct because in Swift 
// a struct is a value type, while a class is a reference type
// cannot use inheritance with structs and structs pass around copies
// instead of references to class instances
struct Swap: Printable, Hashable {
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var hashValue: Int {
        return cookieA.hashValue ^ cookieB.hashValue
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB)
        || (lhs.cookieA == rhs.cookieB && lhs.cookieB == rhs.cookieA)
}
