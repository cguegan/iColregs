//
//  section.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation

struct SectionModel: Identifiable, Decodable {
    let id: String
    let title: String
    let rules: [RuleModel]
}
