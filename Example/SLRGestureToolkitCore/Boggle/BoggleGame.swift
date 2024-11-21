//
//  BoggleGame.swift
//  SLRGestureToolkitCore_Example
//
//  Created by Srivinayak Chaitanya Eshwa on 21/11/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

final class BoggleGame {
    let gridSize: Int
    var board: [[String]]
    private var visited: [[Bool]]
    public var wordDictionary: [String: [(Int, Int)]] = [:]
    public let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    var words: Set<String>
    
    init(gridSize: Int, words: Set<String>) {
        self.gridSize = gridSize
        self.board = Array(repeating: Array(repeating: "", count: gridSize), count: gridSize)
        self.visited = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
        self.words = words
        generateBoard()
    }
    
    public func getDictionary() -> [String: [(Int, Int)]] {
        return wordDictionary
    }
    
    private func generateBoard() {
        for word in words {
            placeWordOnBoard(word)
        }
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for i in 0..<gridSize {
            for j in 0..<gridSize {
                if board[i][j] == "" {
                    board[i][j] = String(letters.randomElement()!)
                }
            }
        }
    }
    
    private func placeWordOnBoard(_ word: String) {
        let wordLength = word.count
        let wordArray = Array(word)
        
        for _ in 0..<100 { // what's a good number of retries?
            let startRow = Int.random(in: 0..<gridSize)
            let startCol = Int.random(in: 0..<gridSize)
            let direction = directions.randomElement()!
            
            if canPlaceWord(wordArray, row: startRow, col: startCol, direction: direction) {
                print("WordArray: \(wordArray)")
                var indices: [(Int, Int)] = []
                for i in 0..<wordLength {
                    let newRow = startRow + i * direction.0
                    let newCol = startCol + i * direction.1
                    indices.append((newRow, newCol))
                    board[newRow][newCol] = String(wordArray[i])
                    print("Row: \(newRow)")
                    print("Column: \(newCol)")
                }
                wordDictionary[word] = indices
                return
            }
        }
        print("Could not place word: \(word)")
    }
    
    private func canPlaceWord(_ wordArray: [Character], row: Int, col: Int, direction: (Int, Int)) -> Bool {
        let wordLength = wordArray.count
        
        for i in 0..<wordLength {
            let newRow = row + i * direction.0
            let newCol = col + i * direction.1
            
            if newRow < 0 || newCol < 0 || newRow >= gridSize || newCol >= gridSize {
                return false
            }
            
            // if we already put a word there
            if board[newRow][newCol] != "" && board[newRow][newCol] != String(wordArray[i]) {
                return false
            }
        }
        return true
    }
}

