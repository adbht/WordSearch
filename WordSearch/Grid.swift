//
//  Grid.swift
//  WordSearch
//
//  Created by Aditya Bhatia on 2019-05-08.
//  Copyright © 2019 adbht. All rights reserved.
//

import UIKit

class Grid {
    
    enum Direction {
        case horizontal
        case vertical
        case forwardDiagonal
        case backwardDiagonal
    }
    
    let results = ["SWIFT", "KOTLIN", "OBJECTIVEC", "VARIABLE", "JAVA", "MOBILE", "PYTHON", "MACBOOK"]
    
    var letters = [[String]](repeating: [String](repeating: String(), count: 10), count: 10)
    var buttons = [UIButton]()
    var buttonOnIndex = [[Int]: UIButton]()
    var buttonPositions = [UIButton: Int]()
    var correctButtonsFound = [UIButton]()
    var currentButtonsSelected = [UIButton]()
    var highlights = String()
    var lastButton = UIButton()
    var wordsFound = Int()
    var setUpComplete = Bool()
    var chosenDirection: Direction?
    
}
