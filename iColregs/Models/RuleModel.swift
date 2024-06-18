//
//  RuleModel.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation

struct RuleModel: Identifiable, Decodable {
    let id: String
    let title: String
    let content: [ContentModel]
    
    
}
