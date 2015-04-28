//
//  Level.swift
//  Cookie Crunch
//
//  Created by Adam on 4/11/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import Foundation

let NumColumns: Int = 9
let NumRows = 9

class Level {
    
    private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var possibleSwaps = Set<Swap>()
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            
            if let tilesArray: AnyObject = dictionary["tiles"] {
                
                for (row, rowArray) in enumerate(tilesArray as! [[Int]]) {
                    let tileRow = NumRows - row - 1
                    
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }
    
    // returns a tile at a column and row
    // if those are valid
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    // returns a cookie at a column and row
    // if those are valid
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }
    
    // creates and shuffles the initial Set of cookies
    // also detects all possible swaps before returning the Set
    func shuffle() -> Set<Cookie> {
        var set: Set<Cookie>
        do {
            set = createInitialCookies()
            detectPossibleSwaps()
            println("possible swaps: \(possibleSwaps)")
        } while possibleSwaps.count == 0
        
        return set
    }
    
    // Swaps the two cookies contained in the Swap object
    func performSwap(swap: Swap) {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeCookies(horizontalChains)
        removeCookies(verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    private func removeCookies(chains: Set<Chain>) {
        for chain in chains {
            for cookie in chain.cookies {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
    // creates the initial Set of cookies
    // Rule for creating initial cookie types.  At the
    // beginning of the game or end of turn, no matches are allowed on the
    // screen (ie. if there is a match should be taken care of)
    private func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column, row] != nil {
                    
                    var cookieType: CookieType
                    
                    // in psuedo code: keep generating a new cookie type if
                    // it matches 2 cookies to the left of it or 2 below it
                    do {
                        cookieType = CookieType.random()
                    } while (column >= 2 &&
                        cookies[column - 1, row]?.cookieType == cookieType &&
                        cookies[column - 2, row]?.cookieType == cookieType)
                        || (row >= 2 &&
                            cookies[column, row - 1]?.cookieType == cookieType &&
                            cookies[column, row - 2]?.cookieType == cookieType)
                    
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    
                    set.insert(cookie)
                }
            }
        }
        return set
    }
    
    // detects all possible swaps after the level has been shuffled
    private func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                // if a cookie is at that column and row and not an empty tile
                if let cookie = cookies[column, row] {
                    
                    // first look to the cookie's right (ie. horizontal swaps)
                    if column < NumColumns - 1 {
                        // if there is a cookie to the cookie's right
                        if let other = cookies[column + 1, row] {
                            
                            // swap them
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            // are either of these cookies part of a potential chain?
                            if hasChainAtColumn(column + 1, row: row) ||
                                hasChainAtColumn(column, row: row) {
                                    set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // put the cookies back in the original spots
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    
                    // next look above the cookie
                    if row < NumRows - 1 {
                        if let other = cookies[column, row + 1] {
                            
                            // swap them
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            // are either cookies part of a chain? 
                            if hasChainAtColumn(column, row: row) ||
                               hasChainAtColumn(column, row: row + 1) {
                                  set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // put both cookies back
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                            
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            
            for var row = 0; row < NumRows - 2; {
                
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column, row + 1]?.cookieType == matchType
                        && cookies[column, row + 2]?.cookieType == matchType {
                            let chain = Chain(chainType: .Vertical)
                            do {
                            
                                chain.addCookie(cookies[column, row]!)
                                ++row
    
                            } while row < NumRows && cookies[column, row]?.cookieType == matchType
                            
                            set.insert(chain)
                            continue
                    }
                }
                
                ++row
            }
        }
        return set
    }
    
    private func detectHorizontalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for row in 0..<NumRows {
            // don't have to check the last 2 rows because
            // we are finding chains from left to right
            for var column = 0; column < NumColumns - 2; {
                
                // skips over any empty cookie tiles
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column + 1, row]?.cookieType == matchType
                        && cookies[column + 2, row]?.cookieType == matchType {
                            let chain = Chain(chainType: .Horizontal)
                            do {
                                chain.addCookie(cookies[column, row]!)
                                ++column
                            } while column < NumColumns && cookies[column, row]?.cookieType == matchType
                            
                            set.insert(chain)
                            continue
                    }
                }
                
                ++column
            }
        }
        
        return set
    }
    
    // returns true if there is a horizontal or vertical
    // chanin at the column and row.  used by detect possible swaps
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && cookies[i, row]?.cookieType == cookieType; --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && cookies[i, row]?.cookieType == cookieType; ++i, ++horzLength { }
       
        // found a horizontal chain through the columns
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && cookies[column, i]?.cookieType == cookieType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && cookies[column, i]?.cookieType == cookieType;
            ++i, ++vertLength { }
    
        // found a vertical chain through the rows
        return vertLength >= 3
    }
}