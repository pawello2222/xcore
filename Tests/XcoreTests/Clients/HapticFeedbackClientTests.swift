//
// Xcore
// Copyright © 2021 Xcore
// MIT license, see LICENSE file for details
//

import XCTest
@testable import Xcore

final class HapticFeedbackClientTests: TestCase {
    func testDefault() {
        let viewModel = ViewModel()
        var triggeredFeedback: HapticFeedbackClient.Style?

        DependencyValues.withValues {
            $0.hapticFeedback = .init(trigger: { style in
                triggeredFeedback = style
            })
        } operation: {
            viewModel.triggerSelectionFeedback()
            XCTAssertEqual(triggeredFeedback, .selection)
        }
    }
}

extension HapticFeedbackClientTests {
    private final class ViewModel {
        @Dependency(\.hapticFeedback) var hapticFeedback

        func triggerSelectionFeedback() {
            hapticFeedback(.selection)
        }
    }
}
