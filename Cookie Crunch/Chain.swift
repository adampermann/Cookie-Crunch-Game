//
//  Chain.swift
//  Cookie Crunch
//
//  Created by Adam on 4/26/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import Foundation

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.cookies == rhs.cookies
}

// scoring rules for chains
// A 3-cookie chain is worth 60 points.
// Each additional cookie in the chain increases the chain’s value by 60 points.
class Chain: CustomStringConvertible, Hashable {
    // using an array rather than a Set
    // so it is easier to detect L and T shaped chains if they
    // happen to exist
    
    var cookies = [Cookie]()
    var score = 0
    enum ChainType: CustomStringConvertible {
        
        // TODO add L and T shape chain types
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addCookie(cookie: Cookie) {
        cookies.append(cookie)
    }
    
    func firstCookie() -> Cookie {
        return cookies[0]
    }
    
    func lastCookie() -> Cookie {
        return cookies[cookies.count - 1]
    }
    
    var length: Int {
        return cookies.count
    }
    
    var description: String {
        return "type:\(chainType) cookies:\(cookies)"
    }
    
    var hashValue: Int {
        // performs an exclusive-or on the hash values of all the cookies in the chain
        return cookies.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
}