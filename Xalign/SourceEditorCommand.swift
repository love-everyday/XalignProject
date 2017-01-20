//
//  SourceEditorCommand.swift
//  Xalign
//
//  Created by Pisen on 2017/1/19.
//  Copyright © 2017年 SMIT. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let lines      = invocation.buffer.lines
        let selections = invocation.buffer.selections
        
        var indexs: [Int] = []
        var lengths: [Int] = []
        var preStrs: [String] = []
        var otherStrs: [String] = []
        
        for selection in selections {
            guard let textRange = selection as? XCSourceTextRange,
                textRange.start.line != lines.count,
                textRange.start.line != textRange.end.line else {
                    continue
            }
            
            var maxLength = 0
            var isFirst = false
            var spaces = ""
            for index in textRange.start.line...textRange.end.line {
                let line = lines[index] as! String
                if line.contains("=") {
                    let strs = line.components(separatedBy: "=")
                    if strs.count == 2 {
                        indexs.append(index)
                        var startLine = strs[0]
                        startLine = startLine.replacingOccurrences(of: "\n", with: "")
                        let ret = removeSpaceAndNewLineCharacter(startLine, type: 2)
                        let preStr = ret.0
                        preStrs.append(preStr)
                        otherStrs.append(removeSpaceAndNewLineCharacter(strs[1], type: 0).0)
                        let length = preStr.characters.count
                        lengths.append(length)
                        if length > maxLength {
                            maxLength = length
                        }
                        
                        if !isFirst, let spaceIndex = ret.1 {
                            isFirst = true
                            spaces = startLine.substring(to: spaceIndex)
                        }
                    }
                }
            }
            
            for (i, index) in indexs.enumerated() {
                let off = maxLength - lengths[i]
                var preStr = preStrs[i]
                for _ in 0..<off {
                    preStr.append(" ")
                }
                let line = spaces + preStr + " = " + otherStrs[i]
                lines.replaceObject(at: index, with: line)
            }
        }
        completionHandler(nil)
    }
    
    func removeSpaceAndNewLineCharacter(_ string: String,type: Int) -> (String, String.Index?, String.Index?) {
        var line = string
        var startIndex: String.Index?
        var endIndex: String.Index?
        
        if type == 0 || type == 2 {
            var charIndex = line.startIndex
            var char = line[charIndex]
            while char == " " || char == "\n" {
                charIndex = line.index(after: charIndex)
                char = line[charIndex]
            }
            line = line.substring(from: charIndex)
            startIndex = charIndex
        }
        if type == 1 || type == 2 {
            var charIndex = line.endIndex
            var char = line[line.index(before: charIndex)]
            while char == " " || char == "\n" {
                charIndex = line.index(before: charIndex)
                char = line[line.index(before: charIndex)]
            }
            line = line.substring(to: charIndex)
            endIndex = charIndex
        }
        return (line, startIndex, endIndex)
    }
    
}
