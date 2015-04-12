//
//  Cookie.swift
//  Cookie Crunch
//
//  Created by Adam on 4/10/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import SpriteKit

enum CookieType: Int, Printable {
    case Unknown = 0, Crossaint, Cupcake, Danish, Donut, Macaroon, SugarCookie
    
    var spriteName: String {
        let spriteNames = [
            "Crossaint",
            "Cupcake",
            "Danish",
            "Donut",
            "Macaroon",
            "SugarCookie"
        ]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> CookieType {
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    var description: String {
        return spriteName
    }
}

func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

class Cookie: Printable, Hashable {
    var row: Int
    var column: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, cookieType: CookieType) {
        self.row = row
        self.column = column
        self.cookieType = cookieType
    }
    
    var hashValue: Int {
        return row * 10 + column
    }
    
    var description: String {
        return "type:\(cookieType) square:(\(column),\(row))"
    }
}