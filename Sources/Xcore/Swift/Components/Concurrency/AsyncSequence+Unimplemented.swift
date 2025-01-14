//
// Xcore
// Copyright © 2022 Xcore
// MIT license, see LICENSE file for details
//

#if DEBUG
// MARK: - AnyAsyncSequence

extension AsyncStream {
    /// Any asynchronous sequence that causes a test to fail if it runs.
    public static func unimplemented(_ prefix: String) -> Self {
        AsyncStream {
            internal_XCTFail("\(prefix.isEmpty ? "" : "\(prefix) - ")A failing asynchronous sequence ran.")
            $0.finish()
        }
    }
}

// MARK: - AsyncThrowingStream

extension AsyncThrowingStream where Failure == Error {
    /// Any asynchronous sequence that causes a test to fail if it runs.
    public static func unimplemented(_ prefix: String) -> Self {
        AsyncThrowingStream {
            internal_XCTFail("\(prefix.isEmpty ? "" : "\(prefix) - ")A failing asynchronous sequence ran.")
            $0.finish()
        }
    }
}

// MARK: - AsyncPassthroughStream

extension AsyncPassthroughStream {
    /// Any asynchronous sequence that causes a test to fail if it runs.
    public static func unimplemented(_ prefix: String) -> Self {
        let stream = Self()
        internal_XCTFail("\(prefix.isEmpty ? "" : "\(prefix) - ")A failing asynchronous sequence ran.")
        stream.finish()
        return stream
    }
}

// MARK: - AsyncCurrentValueStream

extension AsyncCurrentValueStream {
    /// Any asynchronous sequence that causes a test to fail if it runs.
    public static func unimplemented(_ prefix: String, placeholder: Element) -> Self {
        let stream = Self(placeholder)
        internal_XCTFail("\(prefix.isEmpty ? "" : "\(prefix) - ")A failing asynchronous sequence ran.")
        stream.finish()
        return stream
    }
}

// MARK: - AsyncValueStream

extension AsyncValueStream {
    /// Any asynchronous sequence that causes a test to fail if it runs.
    public static func unimplemented(_ prefix: String, placeholder: Element) -> Self {
        let stream = constant(placeholder)
        internal_XCTFail("\(prefix.isEmpty ? "" : "\(prefix) - ")A failing asynchronous sequence ran.")
        return stream
    }
}
#endif
