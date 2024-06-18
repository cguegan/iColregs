//
//  AnnexModel.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation

struct AnnexModel: Identifiable, Decodable {
    let id: String
    let title: String
    let subtitle: String
    let content: [ContentModel]
}
