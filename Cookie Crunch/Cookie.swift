//
//  Cookie.swift
//  Cookie Crunch
//
//  Created by Adam on 4/10/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import SpriteKit

enum CookieType: Int {
    case Unknown = 0, Crossaint, Cupcake, Danish, Donut, Macaroon, SugarCookie
}

class Cookie {
    var row: Int
    var column: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, cookieType: CookieType) {
        self.row = row
        self.column = column
        self.cookieType = cookieType
    }
}