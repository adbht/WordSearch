//
//  ViewController.swift
//  WordSearch
//
//  Created by Aditya Bhatia on 2019-05-08.
//  Copyright © 2019 adbht. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: Properties
    let tapticFeedback = UINotificationFeedbackGenerator()
    var portraitWidth = UIScreen.main.bounds.width - 16
    var portraitHeight = UIScreen.main.bounds.height - 16
    
    var player: AVAudioPlayer?
    var grid = Grid()
    
    // MARK: UI Elements
    let currentWordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 35)
        label.textColor = UIColor(hex: 0x004D40)
        return label
    }()
    
    let gridBackground: UIView = {
        let background = UIView()
        background.layer.cornerRadius = 20.0
        background.backgroundColor = UIColor(hex: 0x26A69A)
        return background
    }()
    
    let gridStack: UIStackView = {
        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.distribution = .fillEqually

        // defining 10 columns for the grid
        for i in [0, 10, 20, 30, 40, 50, 60, 70, 80, 90] {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .fillEqually
            
            // adding 10 buttons in every row of the grid to create 10x10 grid of buttons
            for _ in i ..< i + 10 {
                let button = UIButton()
                button.titleLabel?.font = .systemFont(ofSize: 20)
                button.setTitleColor(.white, for: .normal)
                horizontalStack.addArrangedSubview(button)
            }
            gridStack.addArrangedSubview(horizontalStack)
        }
        return gridStack
    }()
    
    let wordsFoundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "WORDS FOUND: 0 / 8"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = UIColor(hex: 0x004D40)
        return label
    }()
    
    let firstRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        
        let words = ["Swift", "Kotlin", "ObjectiveC", "Variable"]
        for word in words {
            let label = UILabel()
            label.textAlignment = .center
            label.text = word
            label.font = .boldSystemFont(ofSize: 17)
            label.textColor = UIColor(hex: 0x004D40)
            stack.addArrangedSubview(label)
        }
        return stack
    }()
    
    let secondRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        
        let words = ["Java", "Mobile", "Python", "MacBook"]
        for word in words {
            let label = UILabel()
            label.textAlignment = .center
            label.text = word
            label.font = .boldSystemFont(ofSize: 17)
            label.textColor = UIColor(hex: 0x004D40)
            stack.addArrangedSubview(label)
        }
        return stack
    }()
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // adding subviews
        view.addSubview(currentWordLabel)
        view.addSubview(wordsFoundLabel)
        view.addSubview(firstRow)
        view.addSubview(secondRow)
        view.addSubview(gridBackground)
        view.addSubview(gridStack)
        
        // swap width and height if launched in landscape
        if portraitWidth > portraitHeight {
            swap(&portraitHeight, &portraitWidth)
        }
        
        // setting up subviews
        setUpLabels()
        setUpGrid()
        
        // set up pan gesture for swiping
        setUpPanGesture()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // reset the frames for all subviews after the orientaiton is changed
        DispatchQueue.main.async {
            self.setUpLabels()
            self.setUpGrid()
        }
    }
    
    // MARK: Methods
    func setUpLabels() {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            // set the frames for labels in portrait orientation
            currentWordLabel.frame = CGRect(x: 0, y: 75, width: 350, height: 100)
            currentWordLabel.center.x = view.center.x
            currentWordLabel.center.y = view.center.y - portraitHeight / 2.5
            currentWordLabel.font = .boldSystemFont(ofSize: 35)
            
            wordsFoundLabel.font = .boldSystemFont(ofSize: 20)
            wordsFoundLabel.frame = CGRect(x: 0, y: 0, width: portraitWidth, height: portraitWidth + 50)
            wordsFoundLabel.center.x = view.center.x
            wordsFoundLabel.center.y = view.center.y + portraitHeight / 2.8
            
            firstRow.axis = .horizontal
            firstRow.frame = CGRect(x: 0, y: 0, width: portraitWidth, height: portraitWidth + 50)
            firstRow.center.x = view.center.x
            firstRow.center.y = view.center.y + portraitHeight / 2.4
            
            secondRow.axis = .horizontal
            secondRow.frame = CGRect(x: 0, y: 0, width: portraitWidth, height: portraitWidth + 50)
            secondRow.center.x = view.center.x
            secondRow.center.y = view.center.y + portraitHeight / 2.2
        } else {
            // set the frames for labels in landscape orientation
            currentWordLabel.frame = CGRect(x: 0, y: 0, width: portraitHeight / 3, height: portraitWidth)
            currentWordLabel.font = .boldSystemFont(ofSize: 17)
            currentWordLabel.center.x = view.center.x - (portraitHeight / 2.6)
            currentWordLabel.center.y = view.center.y
            
            wordsFoundLabel.font = .boldSystemFont(ofSize: 15)
            wordsFoundLabel.frame = CGRect(x: 0, y: 0, width: portraitHeight / 3, height: portraitWidth)
            wordsFoundLabel.center.x = view.center.x - (portraitHeight / 2.6)
            wordsFoundLabel.center.y = view.center.y - portraitWidth / 3
            
            firstRow.axis = .vertical
            firstRow.frame = CGRect(x: 0, y: 0, width: portraitHeight / 3, height: portraitWidth * 0.45)
            firstRow.center.x = view.center.x + (portraitHeight / 2.6)
            firstRow.center.y = view.center.y - portraitWidth / 4
            
            secondRow.axis = .vertical
            secondRow.frame = CGRect(x: 0, y: 0, width: portraitHeight / 3, height: portraitWidth * 0.45)
            secondRow.center.x = view.center.x + (portraitHeight / 2.6)
            secondRow.center.y = view.center.y + portraitWidth / 4
        }
    }
    
    func setUpGrid() {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            // set the frames for the grid in portrait orientation
            gridBackground.frame = CGRect(x: 0, y: 0, width: portraitWidth, height: portraitWidth + 50)
            gridBackground.center = view.center
            
            gridStack.frame = CGRect(x: 0, y: 0, width: portraitWidth, height: portraitWidth + 50)
            gridStack.center = view.center
        } else {
            // set the frames for the grid in landscape orientation
            gridBackground.frame = CGRect(x: 0, y: 0, width: (portraitHeight / 2), height: portraitWidth)
            gridBackground.center = view.center
            
            gridStack.frame = CGRect(x: 0, y: 0, width: (portraitHeight / 2), height: portraitWidth)
            gridStack.center = view.center
        }
        
        if !grid.setUpComplete {
            grid.setUpComplete.toggle()
            
            // add words to the grid
            for word in grid.results {
                let characters: [Character] = Array(word)
                add(the: characters)
            }
            
            var letters = [String]()
            for x in 0...9 {
                for y in 0...9 {
                    if grid.letters[x][y].isEmpty {
                        // if no letter was added to the button on row x and column y, add random letter
                        let uppercaseLetters = (65...90).map { String(UnicodeScalar($0)) }
                        letters.append(uppercaseLetters.randomElement() ?? "A")
                    } else {
                        // else, append the letters array with the letter in row x column y
                        letters.append(grid.letters[x][y])
                    }
                }
            }
            
            var counter = 0
            var y = 0
            for horizontalStack in gridStack.arrangedSubviews {
                var x = 0
                for view in horizontalStack.subviews {
                    guard let button = view as? UIButton else { return }
                    // append the new buttons to the instance variables in Grid()
                    grid.buttons.append(button)
                    grid.buttonOnIndex[[x, y]] = button
                    grid.buttonPositions[button] = counter
                    // set title on each button with letters array defined earlier
                    button.setTitle(letters[counter], for: .normal)
                    counter += 1
                    x += 1
                }
                y += 1
            }
        }
    }
    
    func add(the word: [Character]) {
        var wordAdded = false
        repeat {
            // to randomly choose between horizontal, vertical
            // and diagonal allocation on words on the empty grid
            let direction = Int.random(in: 1...3)
            // to pick random x and y indices
            let x = Int.random(in: 0...9)
            let y = Int.random(in: 0...9)
            // keep a track of all slots chosen
            var slots = [(Int, Int)]()
            
            switch direction {
            case 1:
                // Horizontal addition of letters
                for counter in 0 ..< word.count {
                    slots.append((x + counter, y))
                }
            case 2:
                // Vertical addition of letters
                for counter in 0 ..< word.count {
                    slots.append((x, y + counter))
                }
            default:
                // Diagonal addition of letters
                for counter in 0 ..< word.count {
                    slots.append((x + counter, y + counter))
                }
            }
            // check if the random choice of slots are all available
            if vacant(for: slots) {
                // if all slots are available, save the allocation choice
                var counter = 0
                for slot in slots {
                    grid.letters[slot.0][slot.1] = String(word[counter])
                    counter += 1
                }
                wordAdded = true
            }
        } while !wordAdded
    }
    
    func vacant(for slots: [(Int, Int)]) -> Bool {
        // if any slot is outside the 10x10 grid, return not vacant
        for slot in slots where slot.0 < 0 || slot.0 > 9 || slot.1 < 0 || slot.1 > 9 {
            return false
        }
        // or, if any slot is filled with a letter, return not vacant
        for slot in slots where !grid.letters[slot.0][slot.1].isEmpty {
            return false
        }
        // else, all slots are vacant
        return true
    }
    
    func checkForLabel(in row: UIStackView) {
        // find all the buttons the user has chosen to find the word
        for button in grid.buttons where button.titleLabel?.font == .boldSystemFont(ofSize: 30) {
            grid.correctButtonsFound.append(button)
        }
        // find the label that shows the new word founded and add a strikethrough
        for subView in row.subviews {
            guard let label = subView as? UILabel else { return }
            if label.text?.uppercased() == grid.highlights {
                let attributeString = NSMutableAttributedString(string: label.text ?? "")
                let strikethrough = NSAttributedString.Key.strikethroughStyle
                let range = NSMakeRange(0, attributeString.length)
                attributeString.addAttribute(strikethrough, value: 2, range: range)
                label.attributedText = attributeString
                break
            }
        }
    }
    
    func setDirection(using button: UIButton) {
        // set a direction to prevent the user to change their choice of direction
        // define the direction based on the choice of first and second button
        guard let previousButton = grid.currentButtonsSelected.first else { return }
        guard let previousButtonPosition = grid.buttonPositions[previousButton] else { return }
        guard let currentButtonPosition = grid.buttonPositions[button] else { return }
        
        // determine the distance between first and second button
        let positionDifference = abs(currentButtonPosition - previousButtonPosition)
        
        // define the chosen direction based on the position difference
        switch positionDifference {
        case 1:
            grid.chosenDirection = .horizontal
        case 9:
            grid.chosenDirection = .backwardDiagonal
        case 10:
            grid.chosenDirection = .vertical
        case 11:
            grid.chosenDirection = .forwardDiagonal
        default:
            grid.chosenDirection = nil
        }
    }
    
    func conformsWithDirection(for button: UIButton) -> Bool {
        // before highlighting over the new button, check if its consistent with direction
        guard let previousButton = grid.currentButtonsSelected.last else { return false }
        guard let previousButtonPosition = grid.buttonPositions[previousButton] else { return false }
        guard let currentButtonPosition = grid.buttonPositions[button] else { return false }
        let positionDifference = abs(currentButtonPosition - previousButtonPosition)
        
        // if the choice of direction matches with position difference, new word conforms
        let validHorizontally = positionDifference == 1 && grid.chosenDirection == .horizontal
        let validVertically = positionDifference == 10 && grid.chosenDirection == .vertical
        let validDiagonally = (positionDifference == 11 && grid.chosenDirection == .forwardDiagonal) ||
                                (positionDifference == 9 && grid.chosenDirection == .backwardDiagonal)
        
        return validHorizontally || validVertically || validDiagonally
    }
    
    func resetAllButtons() {
        // if the user wishes to restart a new game, reset all buttons
        grid.wordsFound = 0
        grid.correctButtonsFound.removeAll()
        wordsFoundLabel.text = "WORDS FOUND: 0 / \(grid.results.count)"
        
        // change the font of all buttons to default value
        for button in grid.buttons {
            button.titleLabel?.font = .systemFont(ofSize: 20)
        }
    }
    
    func showAllWordLabels(in row: UIStackView) {
        // if the user wishes to restart the game, remove strikethroughs on all labels
        for subView in row.subviews {
            guard let label = subView as? UILabel else { return }
            let title = label.text ?? ""
            label.attributedText = nil
            label.text?.removeAll()
            label.text = title
        }
    }
    
    func proceedToSelect(the button: UIButton) {
        guard let buttonTitle = button.currentTitle else { return }
        // change the font of the new letter selected and append button arrays
        grid.currentButtonsSelected.append(button)
        // animating the swipe
        UIView.animate(withDuration: 0.5) {
            button.alpha = 0
            button.alpha = 1
        }
        
        button.titleLabel?.font = .boldSystemFont(ofSize: 30)
        grid.highlights.append(buttonTitle)
        
        // add the new letter to the label displayed on top of grid
        currentWordLabel.text = grid.highlights
        grid.lastButton = button
        
        if grid.results.contains(grid.highlights) {
            // notify the user for finding a word
            tapticFeedback.notificationOccurred(.success)
            playsound(for: "wordFound")
            
            // update the labels
            grid.wordsFound += 1
            wordsFoundLabel.text = "WORDS FOUND: \(grid.wordsFound) / \(grid.results.count)"
            
            // add a strikethough in the label that shows this new word found
            checkForLabel(in: firstRow)
            checkForLabel(in: secondRow)
            
            // if all words found, ask the user if they'd like to reset the game
            if grid.wordsFound == grid.results.count {
                askForReset()
            }
        }
    }
    
    func highlight(the button: UIButton!) {
        // highlight new button if it wasn't the last button highlighted
        // and the count of total chosen letters is less than the largest word
        if grid.lastButton != button && grid.highlights.count < 10 {
            if grid.currentButtonsSelected.isEmpty {
                // if this is the first button, user may pick any direction from here
                proceedToSelect(the: button)
            } else if grid.currentButtonsSelected.count == 1 {
                // if this is the second button, define user's choice of direction
                setDirection(using: button)
                proceedToSelect(the: button)
            } else if conformsWithDirection(for: button) {
                // else, if this button conforms with chosen direction, select it
                proceedToSelect(the: button)
            } else {
                // if user changed their direction, notify an error
                tapticFeedback.notificationOccurred(.error)
                playsound(for: "error")
            }
        }
    }
    
    func askForReset() {
        let title = "CONGRATULATIONS!"
        let message = "You've found all words in the grid."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            // reset all preferences if the user wishes to start a new game
            self.resetAllButtons()
            self.showAllWordLabels(in: self.firstRow)
            self.showAllWordLabels(in: self.secondRow)
            self.grid.letters = [[String]](repeating: [String](repeating: String(), count: 10), count: 10)
            self.grid.setUpComplete = false
            self.setUpGrid()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Extensions
extension ViewController {
    // this extension contains UIPanGesture methods
    func setUpPanGesture() {
        let handlePan = #selector(handlePan(for:))
        let pan = UIPanGestureRecognizer(target: self, action: handlePan)
        gridStack.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(for gesture: UIPanGestureRecognizer) {
        let coordinates = gesture.location(in: gridStack)
        // find the height and width of individual buttons to find index using coordinates
        let height = gridStack.frame.height / 10
        let width = gridStack.frame.width / 10
        let index = [Int(coordinates.x / width), Int(coordinates.y / height)]
        
        if gesture.state == .began || gesture.state == .changed {
            // retrieve the button based on the index defined
            guard let button = grid.buttonOnIndex[index] else { return }
            // if a button was found on this index, highlight this button
            highlight(the: button)
        } else {
            // reset the button fonts for the buttons that didn't belong to any word after swiping
            for button in grid.buttons where !grid.correctButtonsFound.contains(button) {
                button.titleLabel?.font = .systemFont(ofSize: 20)
            }
            // remove highlighted letters that didn't belong to any word after swiping
            grid.highlights.removeAll()
            currentWordLabel.text?.removeAll()
            grid.currentButtonsSelected.removeAll()
        }
    }
}

extension ViewController {
    // this extension contains AVFoundation methods
    func playsound(for resource: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension UIColor {
    // this extension for UIColor is used to set colors using hex values
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
