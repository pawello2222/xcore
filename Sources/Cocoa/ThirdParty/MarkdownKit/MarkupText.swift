//
// MarkupText.swift
//
// Copyright © 2017 Xcore
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

#if canImport(Haring)
import Haring

// MARK: - MarkupText

public class MarkupText: CustomStringConvertible {
    private var markupText: MarkupTextBuilder

    /// The unformatted representation of the markup text.
    public let rawValue: String

    public init(_ text: String) {
        rawValue = text
        markupText = .text(text)
    }

    public func font(_ font: UIFont) -> MarkupText {
        markupText = markupText.addFont(font)
        return self
    }

    public func color(_ color: UIColor) -> MarkupText {
        markupText = markupText.addColor(color)
        return self
    }

    public func underline() -> MarkupText {
        markupText = markupText.addUnderline()
        return self
    }

    public func bold() -> MarkupText {
        markupText = markupText.addBold()
        return self
    }

    public var description: String {
        markupText.description
    }
}

// MARK: - MarkupTextBuilder

private indirect enum MarkupTextBuilder: CustomStringConvertible {
    case text(_: String)
    case textColor(color: String, block: MarkupTextBuilder)
    case font(font: UIFont, block: MarkupTextBuilder)
    case underline(block: MarkupTextBuilder)
    case bold(block: MarkupTextBuilder)

    func addFont(_ font: UIFont) -> MarkupTextBuilder {
        .font(font: font, block: self)
    }

    func addColor(_ color: UIColor) -> MarkupTextBuilder {
        .textColor(color: color.hex, block: self)
    }

    func addUnderline() -> MarkupTextBuilder {
        .underline(block: self)
    }

    func addBold() -> MarkupTextBuilder {
        .bold(block: self)
    }

    var description: String {
        MarkupTextBuilder.parse(self)
    }
}

extension MarkupTextBuilder {
    private static func parse(_ block: MarkupTextBuilder) -> String {
        switch block {
            case .text(let text):
                return text
            case .textColor(let (color, tail)):
                return "{\(color)|\(parse(tail))}"
            case .font(let (font, tail)):
                return "{font:\(font.fontName),\(font.pointSize)pt|\(parse(tail))}"
            case .underline(let tail):
                return "=_\(parse(tail))=_"
            case .bold(let tail):
                return "**\(parse(tail))**"
        }
    }
}

// MARK: - MarkupText: Local Link

extension MarkupText {
    /// Creates a local link with custom scheme. This ensures that the link plays
    /// nicely with accessibility.
    ///
    /// This is useful to create links in attributed string that has local action
    /// handler.
    public static func localLink(text: String) -> String {
        let linkText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? text
        let linkUrl = "\(URL.Scheme.localLink)://\(linkText)"
        return "[\(text)](\(linkUrl))"
    }
}

// MARK: - Scheme

extension URL.Scheme {
    public static let localLink: URL.Scheme = "locallink"
}

#endif
