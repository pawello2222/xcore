//
// Xcore
// Copyright © 2021 Xcore
// MIT license, see LICENSE file for details
//

import XCTest
@testable import Xcore

final class PasteboardClientTests: TestCase {
    func testInMemoryVariant() {
        let viewModel = ViewModel()

        DependencyValues.withValues {
            $0.pasteboard = .inMemory
        } operation: {
            // nil out the pasteboard
            globalPasteboard = nil
            XCTAssertNil(globalPasteboard)

            viewModel.copy()
            XCTAssertEqual(globalPasteboard, "hello")
        }
    }

    func testNoopVariant() {
        let viewModel = ViewModel()

        DependencyValues.withValues {
            $0.pasteboard = .noop
        } operation: {
            // nil out the pasteboard
            globalPasteboard = nil
            XCTAssertNil(globalPasteboard)

            viewModel.copy()
            XCTAssertNil(globalPasteboard) // current variant is noop
        }
    }

    private final class ViewModel {
        @Dependency(\.pasteboard) var pasteboard

        func copy() {
            pasteboard.copy("hello")
        }
    }
}

// MARK: - Helpers

private var globalPasteboard: String?

extension PasteboardClient {
    /// Returns in-memory variant of `PasteboardClient`.
    fileprivate static var inMemory: Self {
        .init { string in
            globalPasteboard = string
        }
    }
}
