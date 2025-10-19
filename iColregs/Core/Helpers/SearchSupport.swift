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

// Lightweight view model describing a single hit returned by the search engine.
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

// Declarative configuration defining how the search UI should present itself.
struct PartSearchConfiguration {
  let resultsTitle: String
  let noResultsMessage: String
  let searchPlaceholder: String
  let rulesSectionTitle: String
  let ruleDetailTitle: String
  let articleDetailTitle: String
  let matchLabel: (Int) -> String
}

/// Scans the provided parts and returns every rule/annex that matches the query.
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

/// Highlights each occurrence of `query` inside markdown-formatted `text` and returns a SwiftUI `Text`.
/// - Parameters:
///  - text: Full markdown text to process.
///  - query: Substring to highlight.
///  - highlightColor: Background color used for highlighting (default: semi-transparent yellow).
/// - Returns: SwiftUI `Text` with highlighted substrings.
///
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

/// SwiftUI View representing a section of search results.
/// - Parameters:
///  - configuration: Configuration object defining UI texts and labels.
///  - query:         Raw user query (used for highlighting).
///  - results:       Collection of `SearchResult` objects to display.
/// - Returns:        A SwiftUI `View` displaying the search results.
///
struct PartSearchResultsSection: View {
  
  let configuration: PartSearchConfiguration
  let query: String
  let results: [SearchResult]
  
  var body: some View {
    Section(configuration.resultsTitle) {
      if results.isEmpty {
        Text(configuration.noResultsMessage)
          .foregroundStyle(.secondary)
      } else {
        ForEach(results) { result in
          NavigationLink {
            RuleView(
              rule: result.rule,
              title: result.detailTitle,
              highlightTerm: query
            )
          } label: {
            SearchResultRow(
              result: result,
              query: query,
              matchLabel: configuration.matchLabel
            )
          }
        }
      }
    }
  }
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

/// SwiftUI View representing a single search result row.
/// - Parameters:
///  - result:      The `SearchResult` to display.
///  - query:       The raw user query (used for highlighting).
///  - matchLabel:  Closure that returns a localized label for the number of matches.
/// - Returns:      A SwiftUI `View` displaying the search result.
///
private struct SearchResultRow: View {
  
  let result: SearchResult
  let query: String
  let matchLabel: (Int) -> String
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "\(result.rule.id).square.fill")
        .font(.title3)
        .foregroundStyle(result.source == .annex ? Color.orange : Color.accentColor)
        .accessibilityHidden(true)
        .padding(.top, 2)
      VStack(alignment: .leading, spacing: 4) {
        Text(result.displayTitle)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.primary)
          .lineLimit(2)
        Text(result.contextDescription)
          .font(.caption)
          .foregroundStyle(.secondary)
        markdownHighlightedText(result.snippet, query: query)
          .font(.footnote)
          .foregroundStyle(.secondary)
        Text("\(result.matchCount) \(matchLabel(result.matchCount))")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 6)
  }
}
