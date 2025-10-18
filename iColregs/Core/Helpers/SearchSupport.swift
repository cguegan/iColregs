//
//  SearchSupport.swift
//  iColregs
//
//  Created by Christophe Guégan on 26/10/2025.
//

import Foundation
import SwiftUI

enum SearchSource: String {
  case rule
  case annex
}

struct SearchResult: Identifiable {
  let id: String
  let rule: RuleModel
  let partTitle: String
  let sectionTitle: String?
  let detailTitle: String
  let source: SearchSource
  let snippet: String
  let matchCount: Int

  var displayTitle: String {
    "\(detailTitle) \(rule.id): \(rule.title)"
  }

  var contextDescription: String {
    if let sectionTitle, !sectionTitle.isEmpty {
      return "\(partTitle) • \(sectionTitle)"
    }
    return partTitle
  }
}

func performSearch(in parts: [PartModel],
                   query: String,
                   detailTitle: String,
                   source: SearchSource,
                   snippetRadius: Int = 45) -> [SearchResult] {
  let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else { return [] }

  var results: [SearchResult] = []

  for part in parts {
    for section in part.sections {
      for rule in section.rules {
        let titleMatches = ranges(of: trimmed, in: rule.title).count
        var totalMatches = titleMatches
        var firstSnippet: String?

        for content in rule.content {
          let matches = ranges(of: trimmed, in: content.text)
          totalMatches += matches.count
          if firstSnippet == nil, let matchRange = matches.first {
            firstSnippet = snippet(for: content.text,
                                   around: matchRange,
                                   radius: snippetRadius)
          }
        }

        if firstSnippet == nil, titleMatches > 0 {
          firstSnippet = snippet(for: rule.title,
                                 around: ranges(of: trimmed, in: rule.title).first,
                                 radius: snippetRadius)
        }

        if totalMatches > 0 {
          let snippetText = firstSnippet ?? rule.title
          let resultID = "\(source.rawValue)-\(part.id)-\(rule.id)"
          results.append(
            SearchResult(id: resultID,
                         rule: rule,
                         partTitle: part.title,
                         sectionTitle: section.title,
                         detailTitle: detailTitle,
                         source: source,
                         snippet: snippetText,
                         matchCount: totalMatches)
          )
        }
      }
    }
  }

  return results.sorted { lhs, rhs in
    if lhs.matchCount == rhs.matchCount {
      return lhs.rule.id < rhs.rule.id
    }
    return lhs.matchCount > rhs.matchCount
  }
}

func highlightedText(_ text: String,
                     query: String,
                     highlightColor: Color = Color.yellow.opacity(0.35)) -> Text {
  guard !query.isEmpty else { return Text(text) }

  let matchRanges = ranges(of: query, in: text)
  guard !matchRanges.isEmpty else { return Text(text) }

  var composed = AttributedString()
  var cursor = text.startIndex

  for matchRange in matchRanges {
    if cursor < matchRange.lowerBound {
      let prefix = text[cursor..<matchRange.lowerBound]
      composed.append(AttributedString(String(prefix)))
    }

    var highlighted = AttributedString(String(text[matchRange]))
    highlighted.backgroundColor = highlightColor
    composed.append(highlighted)
    cursor = matchRange.upperBound
  }

  if cursor < text.endIndex {
    let suffix = text[cursor..<text.endIndex]
    composed.append(AttributedString(String(suffix)))
  }

  return Text(composed)
}

private func ranges(of query: String, in text: String) -> [Range<String.Index>] {
  guard !query.isEmpty else { return [] }
  var results: [Range<String.Index>] = []
  var searchStart = text.startIndex

  while searchStart < text.endIndex,
        let range = text.range(of: query,
                               options: [.caseInsensitive, .diacriticInsensitive],
                               range: searchStart..<text.endIndex,
                               locale: .current) {
    results.append(range)
    searchStart = range.upperBound
  }

  return results
}

private func snippet(for text: String,
                     around range: Range<String.Index>?,
                     radius: Int) -> String {
  guard let range else { return text }

  let lowerBound = text.index(range.lowerBound,
                              offsetBy: -radius,
                              limitedBy: text.startIndex) ?? text.startIndex
  let upperBound = text.index(range.upperBound,
                              offsetBy: radius,
                              limitedBy: text.endIndex) ?? text.endIndex

  var snippet = String(text[lowerBound..<upperBound])

  if lowerBound > text.startIndex {
    snippet = "…" + snippet
  }

  if upperBound < text.endIndex {
    snippet += "…"
  }

  return snippet
}
