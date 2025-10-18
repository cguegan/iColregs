//
//  SearchSupport.swift
//  iColregs
//
//  Created by Christophe Guégan on 26/10/2025.
//

import Foundation
import SwiftUI

/// Identifies whether a match belongs to a rule or an annex.
///
enum SearchSource: String {
  case rule
  case annex
}

/// View-model representing a single search hit and its metadata.
///
struct SearchResult: Identifiable {
  let id: String
  let rule: RuleModel
  let partTitle: String
  let sectionTitle: String?
  let detailTitle: String
  let source: SearchSource
  let snippet: String
  let matchCount: Int

  // Computed properties for display purposes
  var displayTitle: String {
    "\(detailTitle) \(rule.id): \(rule.title)"
  }

  // Context description combining part and section titles
  var contextDescription: String {
    if let sectionTitle, !sectionTitle.isEmpty {
      return "\(partTitle) • \(sectionTitle)"
    }
    return partTitle
  }
}

/// Scans the provided parts and returns every rule/annex that matches the query.
///
/// - Parameters:
///   - parts: Collection of parts to inspect.
///   - query: Raw user query (will be trimmed/validated).
///   - detailTitle: Localized label used when pushing the detail screen.
///   - source: Origin of the records (`.rule` or `.annex`).
///   - snippetRadius: Number of characters kept on each side of the first match for display.
/// - Returns: Sorted list of results (highest match count first).
///
func performSearch( in parts: [PartModel],
                    query: String,
                    detailTitle: String,
                    source: SearchSource,
                    snippetRadius: Int = 45 ) -> [SearchResult] {
  
  let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty else { return [] }

  var results: [SearchResult] = []

  /// Iterate through every rule in each part/section to find matches.
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

  /// Sort results by match count (highest first), then by rule ID.
  return results.sorted { lhs, rhs in
    if lhs.matchCount == rhs.matchCount {
      return lhs.rule.id < rhs.rule.id
    }
    return lhs.matchCount > rhs.matchCount
  }
}

/// Highlights each occurrence of `query` inside `text` and returns a SwiftUI `Text`.
/// - Parameters:
///   - text: Full text to process.
///   - query: Substring to highlight.
///   - highlightColor: Background color used for highlighting (default: semi-transparent yellow).
/// - Returns: SwiftUI `Text` with highlighted substrings.
///
func highlightedText(_ text: String,
                     query: String,
                     highlightColor: Color = Color.yellow.opacity(0.35)) -> Text {
  guard !query.isEmpty else { return Text(text) }

  let matchRanges = ranges(of: query, in: text)
  guard !matchRanges.isEmpty else { return Text(text) }

  var attributedString: AttributedString

  if let markdown = try? AttributedString(
    markdown: text,
    options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
  ) {
    attributedString = markdown
  } else {
    attributedString = AttributedString(text)
  }

  for range in matchRanges {
    if let lower = AttributedString.Index(range.lowerBound, within: attributedString),
       let upper = AttributedString.Index(range.upperBound, within: attributedString) {
      attributedString[lower..<upper].backgroundColor = highlightColor
    }
  }

  return Text(attributedString)
}

func markdownHighlightedText(_ text: String,
                             query: String,
                             highlightColor: Color = Color.yellow.opacity(0.35)) -> Text {
  let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

  guard !trimmedQuery.isEmpty else {
    if let attributed = try? AttributedString(
      markdown: text,
      options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
    ) {
      return Text(attributed)
    }
    return Text(text)
  }

  guard var attributed = try? AttributedString(
    markdown: text,
    options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
  ) else {
    return highlightedText(text, query: trimmedQuery, highlightColor: highlightColor)
  }

  let plain = String(attributed.characters)
  for range in ranges(of: trimmedQuery, in: plain) {
    if let lower = AttributedString.Index(range.lowerBound, within: attributed),
       let upper = AttributedString.Index(range.upperBound, within: attributed) {
      attributed[lower..<upper].backgroundColor = highlightColor
    }
  }

  return Text(attributed)
}

/// Utility to fetch every case/diacritic-insensitive range of `query` within `text`.
/// - Parameters:
///  - query: Substring to search for.
///  - text: Full text to inspect.
/// - Returns: Array of ranges where `query` occurs within `text`.
///
private func ranges( of query: String,
                     in text: String ) -> [Range<String.Index>] {
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

/// Extracts a short snippet around the first matched range so result rows remain compact.
/// - Parameters:
///  - text: Full text to extract from.
///  - range: Range around which to build the snippet.
///  - radius: Number of characters to keep on each side of the range.
/// - Returns: Snippet string with ellipses if truncated.
///
private func snippet( for text: String,
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
