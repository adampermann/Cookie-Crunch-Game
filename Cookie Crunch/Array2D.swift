//
//  Array2D.swift
//  Cookie Crunch
//
//  Created by Adam on 4/11/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import Foundation

struct Array2D<T> {
    let columns: Int
    let rows: Int
    private var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.array = Array<T?>(count: rows * columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
           return array[row * self.columns + column]
        }
        set {
            array[row * self.columns + column] = newValue
        }
    }
}