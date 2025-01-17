//
// Xcore
// Copyright © 2022 Xcore
// MIT license, see LICENSE file for details
//

import Foundation
import StoreKit

/// Provides functionality to request an App Store rating or review from the
/// user, if appropriate.
///
/// **Usage**
///
/// ```swift
/// class ViewModel {
///     @Dependency(\.requestReview) var requestReview
///
///     func askToRateApp() {
///         requestReview()
///     }
/// }
/// ```
public struct RequestReviewClient {
    private let request: () -> Void

    /// Creates a client to request an App Store rating or review from the user, if
    /// appropriate.
    ///
    /// - Parameter request: The closure to request an App Store rating or review
    ///   from the user, if appropriate.
    public init(request: @escaping () -> Void) {
        self.request = request
    }

    /// Tells StoreKit to request an App Store rating or review from the user, if
    /// appropriate.
    ///
    /// - Note: This may or may not show any UI.
    ///
    /// Although you normally call this instance to request a review when it makes
    /// sense in the user experience flow of your app, the App Store policy governs
    /// the actual display of the rating and review request view. Because calling
    /// this instance may not present an alert, don’t call it in response to a user
    /// action, such as a button tap.
    public func callAsFunction() {
        request()
    }
}

// MARK: - Variants

extension RequestReviewClient {
    /// Returns noop variant of `RequestReviewClient`.
    public static var noop: Self {
        .init {}
    }

    #if DEBUG
    /// Returns unimplemented variant of `RequestReviewClient`.
    public static var unimplemented: Self {
        .init {
            internal_XCTFail("\(Self.self) is unimplemented")
        }
    }
    #endif

    /// Returns live variant of `RequestReviewClient`.
    public static var live: Self {
        .init {
            guard
                FeatureFlag.reviewPromptEnabled,
                let scene = UIApplication.sharedOrNil?.firstSceneKeyWindow?.windowScene
            else {
                return
            }

            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

// MARK: - Dependency

extension DependencyValues {
    private struct RequestReviewClientKey: DependencyKey {
        static let liveValue: RequestReviewClient = .live
    }

    /// Provides functionality for requesting App Store ratings and reviews from
    /// users.
    public var requestReview: RequestReviewClient {
        get { self[RequestReviewClientKey.self] }
        set { self[RequestReviewClientKey.self] = newValue }
    }
}
