//
//  PartModel.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation

struct PartModel: Identifiable, Decodable {
    let id: String
    let title: String
    let sections: [SectionModel]
}
