//
// StackingDataSource+Cells.swift
//
// Copyright © 2019 Xcore
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

// MARK: - HeaderCell

extension StackingDataSource {
    final class HeaderCell: XCCollectionViewCell {
        lazy var hideButton = UIButton(configuration: .plain).apply {
            $0.contentHorizontalAlignment = .leading
            $0.action { [weak self] _ in
                self?.didTapHideAction?()
            }
        }

        lazy var clearButton = UIButton(configuration: .plain).apply {
            $0.contentHorizontalAlignment = .trailing
            $0.action { [weak self] _ in
                self?.didTapClearAction?()
            }
        }

        private var didTapHideAction: (() -> Void)?
        private var didTapClearAction: (() -> Void)?

        private lazy var stackView = UIStackView(arrangedSubviews: [
            hideButton,
            clearButton
        ]).apply {
            $0.distribution = .equalSpacing
        }

        override func commonInit() {
            contentView.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.height.equalTo(30)
                make.leading.trailing.equalToSuperview().inset(.defaultPadding)
                make.top.bottom.equalToSuperview()
            }
            layer.zPosition = -1000
        }

        func configure(didTapHide: @escaping () -> Void, didTapClear: @escaping () -> Void) {
            didTapHideAction = didTapHide
            didTapClearAction = didTapClear
        }
    }
}

// MARK: - Stacking Effect

extension StackingDataSource {
    final class StackEffect: XCCollectionViewCell {
        private lazy var stackView = UIStackView(arrangedSubviews: [
            firstBottomView,
            secondBottomView
        ]).apply {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = -2
            firstBottomView.snp.makeConstraints { make in
                make.height.equalTo(AppConstants.tileCornerRadius)
                make.leading.trailing.equalToSuperview().inset(.minimumPadding)
            }
            secondBottomView.snp.makeConstraints { make in
                make.height.equalTo(AppConstants.tileCornerRadius)
                make.leading.trailing.equalToSuperview().inset(.minimumPadding * 1.8)
            }
            secondBottomView.layer.zPosition = firstBottomView.layer.zPosition - 1
        }

        private let firstBottomView = UIView().apply {
            $0.backgroundColor = UIColor.white.crossFade(to: UIColor(hex: "E6ECF3"), delta: 0.5).darker(0.15)
        }

        private let secondBottomView = UIView().apply {
            $0.backgroundColor = UIColor.white.crossFade(to: UIColor(hex: "E6ECF3"), delta: 0.8).darker(0.08)
        }

        override var bounds: CGRect {
            didSet {
                stackView.layoutIfNeeded()
                roundLowerCorner(of: firstBottomView)
                roundLowerCorner(of: secondBottomView)
            }
        }

        override func commonInit() {
            contentView.addSubview(stackView)
            contentView.clipsToBounds = true
            stackView.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(-1)
                make.leading.trailing.bottom.equalToSuperview()
            }
            layer.zPosition = -1000
        }

        private func roundLowerCorner(of view: UIView) {
            let cornerRadius: CGFloat = AppConstants.tileCornerRadius
            let path = CGMutablePath()
            path.move(to: CGPoint.zero)
            path.addRelativeArc(
                center: CGPoint(x: view.frame.width - cornerRadius, y: 0.0),
                radius: cornerRadius,
                startAngle: 0,
                delta: .pi2
            )
            path.addRelativeArc(
                center: CGPoint(x: cornerRadius, y: 0.0),
                radius: cornerRadius,
                startAngle: .pi2,
                delta: .pi2
            )
            view.layer.masksToBounds = true
            view.layer.mask = CAShapeLayer().apply {
                $0.path = path
            }
        }

        func configure(isTwoOrMore: Bool) {
            secondBottomView.isHidden = !isTwoOrMore
        }
    }
}
