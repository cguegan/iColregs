//
//  ContentModel.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation
import SwiftUI

struct ContentModel: Identifiable, Decodable {
    let indent: String
    let text: String
    let image: String?
    
    var id: String {
        UUID().uuidString
    }
    
    var content: LocalizedStringKey {
        return LocalizedStringKey(text)
    }
    
    var levels: String {
        
        var currentLevel = ""
        
        for level in indent.components(separatedBy: "_") {
            // Paragraph
            if level == "p" {
                return ""
            // Add
            } else if level != "" && level != "•" {
                currentLevel = currentLevel + "(\(level))\t"
            } else if level == "•" {
                // Add
                currentLevel = currentLevel + "\(level)"
            } else {
                // Add tab if -
                currentLevel = currentLevel + "\t"
            }
        }
        
        return currentLevel
        
    }
}
