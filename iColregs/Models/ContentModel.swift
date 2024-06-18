//
//  ContentModel.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation

struct ContentModel: Identifiable, Decodable {
    let id: String = UUID().uuidString
    let indent: String
    let text: String
}
