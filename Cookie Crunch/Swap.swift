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
struct Swap {
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}