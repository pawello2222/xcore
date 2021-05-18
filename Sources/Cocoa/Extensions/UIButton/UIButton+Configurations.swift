//
// Xcore
// Copyright © 2018 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

// MARK: - Identifier<UIButton>

extension Identifier where Type: UIButton {
    /// A style used to set base attributes that we fallback to if any of the
    /// specific style doesn't have given attribute set.
    ///
    /// ```swift
    /// UIButton.defaultAppearance.apply {
    ///     $0.styleAttributes.style(.base).setFont(.appButton())
    ///     $0.styleAttributes.style(.base).setTextColor(.systemBlue)
    ///
    ///     let plainStyleFont = $0.styleAttributes.style(.plain).font(button: UIButton())
    ///     // print(".appButton()", plainStyleFont == .appButton())
    ///     // true
    ///
    ///     let plainStyleTextColor = $0.styleAttributes.style(.plain).textColor(button: UIButton())
    ///     // print(".systemBlue", plainStyleTextColor == .systemBlue)
    ///     // true
    /// }
    /// ```
    public static var base: Self { #function }
    public static var plain: Self { #function }
    public static var callout: Self { #function }
    public static var calloutSecondary: Self { #function }
    public static var pill: Self { #function }
    public static var caret: Self { #function }
    public static var radioButton: Self { #function }
    public static var checkbox: Self { #function }
}

// MARK: - Main Configurations

extension Configuration where Type: UIButton {
    private static func configure(_ button: UIButton, _ id: Identifier) {
        UIButton.defaultAppearance._configure?(button, id as! UIButton.Configuration.Identifier)
    }

    public static var plain: Self {
        .plain()
    }

    public static func plain(
        font: UIFont? = nil,
        textColor: UIColor? = nil,
        alignment: UIControl.ContentHorizontalAlignment = .center
    ) -> Self {
        let id: Identifier = .plain
        return .init(id: id) {
            let textColor = textColor ?? id.textColor
            $0.titleLabel?.font = font ?? id.font(button: $0)
            $0.contentEdgeInsets = .zero
            $0.isHeightSetAutomatically = false
            $0.setTitleColor(textColor, for: .normal)
            $0.setTitleColor(textColor.alpha(textColor.alpha * 0.5), for: .highlighted)
            $0.contentHorizontalAlignment = alignment
            $0.cornerRadius = 0
            configure($0, id)
        }
    }

    public static var callout: Self {
        callout()
    }

    public static func callout(
        font: UIFont? = nil,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil
    ) -> Self {
        let id: Identifier = .callout
        return .init(id: id) {
            var textColor = textColor ?? id.textColor
            let backgroundColor = backgroundColor ?? id.backgroundColor

            if backgroundColor == textColor {
                textColor = backgroundColor.isLight() ? Theme.accentColor : .white
            }

            $0.titleLabel?.font = font ?? id.font(button: $0)
            $0.setTitleColor(textColor, for: .normal)
            $0.backgroundColor = backgroundColor
            $0.disabledBackgroundColor = id.disabledBackgroundColor
            $0.cornerRadius = id.cornerRadius
            configure($0, id)
        }
    }

    public static var calloutSecondary: Self {
        let id: Identifier = .calloutSecondary
        return callout.extend(id: id) {
            $0.setTitleColor(id.textColor, for: .normal)
            $0.backgroundColor = id.backgroundColor
            $0.disabledBackgroundColor = id.disabledBackgroundColor
            $0.borderColor = id.borderColor
            configure($0, id)
        }
    }

    public static var pill: Self {
        let id: Identifier = .pill
        return callout.extend(id: id) {
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.titleLabel?.lineBreakMode = .byTruncatingTail
            $0.backgroundColor = id.backgroundColor
            $0.disabledBackgroundColor = id.disabledBackgroundColor
            $0.cornerRadius = $0.defaultAppearance.height / 2
            configure($0, id)
        }
    }
}

// MARK: - Images Configurations

extension Configuration where Type: UIButton {
    public static var leftArrow: Self {
        image(assetIdentifier: .arrowLeftIcon, alpha: 0.5).extend {
            $0.accessibilityIdentifier = "leftButton"
        }
    }

    public static var rightArrow: Self {
        image(assetIdentifier: .arrowRightIcon, alpha: 0.5).extend {
            $0.accessibilityIdentifier = "rightButton"
        }
    }

    public static var dismiss: Self {
        image(assetIdentifier: .closeIcon, size: .init(24), axis: .horizontal, .vertical)
    }

    public static var dismissFilled: Self {
        image(assetIdentifier: .closeIconFilled, size: .init(24), axis: .horizontal, .vertical)
    }

    public static var searchIcon: Self {
        image(assetIdentifier: .searchIcon, size: .init(14), axis: .horizontal)
    }

    public static func image(
        id: String = #function,
        assetIdentifier: ImageAssetIdentifier,
        size: CGSize,
        axis: NSLayoutConstraint.Axis...
    ) -> Self {
        image(id: id, assetIdentifier: assetIdentifier).extend {
            $0.resistsSizeChange(axis: axis)
            // Increase the touch area if the image size is small.
            if let size = $0.image?.size, size.width < 44 || size.height < 44 {
                $0.touchAreaEdgeInsets = -10
            }
            $0.anchor.make {
                $0.size.equalTo(size).priority(.stackViewSubview)
            }
        }
    }

    public static func image(
        id: String = #function,
        assetIdentifier: ImageAssetIdentifier,
        alpha: CGFloat? = nil
    ) -> Self {
        let id = Identifier(rawValue: id)
        return .init {
            $0.isHeightSetAutomatically = false
            $0.text = nil
            $0.imageView?.isContentModeAutomaticallyAdjusted = true
            $0.contentTintColor = id.tintColor(button: $0)
            $0.contentEdgeInsets = .zero

            let image = UIImage(assetIdentifier: assetIdentifier)

            if let alpha = alpha {
                let originalRenderingMode = image.renderingMode
                $0.image = image.alpha(alpha).withRenderingMode(originalRenderingMode)
                $0.highlightedImage = image.alpha(alpha * 0.5).withRenderingMode(originalRenderingMode)
            } else {
                $0.image = image
            }

            configure($0, id)
        }
    }

    public static func caret(
        in configuration: Configuration = .plain,
        text: String,
        font: UIFont? = nil,
        textColor: UIColor? = nil,
        direction: NSAttributedString.CaretDirection = .forward,
        animated: Bool = false
    ) -> Self {
        let id: Identifier = .caret
        return configuration.extend(id: id) {
            let textColor = textColor ?? configuration.id.textColor
            let font = font ?? configuration.id.font(button: $0)
            $0.titleLabel?.numberOfLines = 1

            let attributedText = NSAttributedString(string: text, font: font, color: textColor, direction: direction, for: .normal)
            $0.setText(attributedText, animated: animated)

            let highlightedAttributedText = NSAttributedString(string: text, font: font, color: textColor, direction: direction, for: .highlighted)
            $0.setAttributedTitle(highlightedAttributedText, for: .highlighted)
            configure($0, id)
        }
    }
}

// MARK: - Toggle Configurations

extension Configuration where Type: UIButton {
    public static var checkbox: Self {
        checkbox()
    }

    public static func checkbox(
        normalColor: UIColor? = nil,
        selectedColor: UIColor? = nil,
        textColor: UIColor? = nil,
        font: UIFont? = nil,
        size: CGFloat? = 24
    ) -> Self {
        let id: Identifier = .checkbox
        return .init(id: id) {
            let normalColor = normalColor ?? id.tintColor(button: $0)
            let selectedColor = selectedColor ?? id.tintColor(button: $0)
            let textColor = textColor ?? id.textColor
            let font = font ?? id.font(button: $0)

            $0.accessibilityIdentifier = "checkboxButton"
            $0.textColor = textColor
            $0.titleLabel?.font = font
            $0.titleLabel?.numberOfLines = 0
            $0.contentHorizontalAlignment = .left
            $0.adjustsImageWhenHighlighted = false
            $0.adjustsBackgroundColorWhenHighlighted = false
            $0.highlightedBackgroundColor = .clear
            $0.highlightedAnimation = .none
            $0.textImageSpacing = 0
            $0.contentEdgeInsets = 0

            if let size = size {
                if $0.constraints.firstAttribute(.width) != nil {
                    // Updated existing constraints.
                    $0.constraints.firstAttribute(.width)?.constant = size
                    $0.constraints.firstAttribute(.height)?.constant = size
                } else {
                    // Created existing constraints.
                    $0.anchor.make {
                        $0.size.equalTo(size)
                    }
                }
            }

            let unfilledImage = UIImage(assetIdentifier: .checkmarkIconUnfilled)
            let filledImage = UIImage(assetIdentifier: .checkmarkIconFilled)
            $0.setImage(unfilledImage.tintColor(normalColor), for: .normal)
            $0.setImage(filledImage.tintColor(selectedColor), for: .selected)
            configure($0, id)
        }
    }

    public static var radioButton: Self {
        radioButton()
    }

    public static func radioButton(
        selectedColor: UIColor? = nil,
        borderColor: UIColor? = nil,
        borderWidth: CGFloat = 0.5,
        size: CGFloat = 24
    ) -> Self {
        let id: Identifier = .radioButton
        return .init(id: id) {
            let selectedColor = selectedColor ?? id.selectedColor
            let borderColor = (borderColor ?? id.borderColor).cgColor

            $0.accessibilityIdentifier = "radioButton"
            $0.layer.borderWidth = borderWidth
            $0.layer.borderColor = borderColor
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = size / 2

            if $0.constraints.firstAttribute(.width) != nil {
                // Updated existing constraints.
                $0.constraints.firstAttribute(.width)?.constant = size
                $0.constraints.firstAttribute(.height)?.constant = size
            } else {
                // Created existing constraints.
                $0.anchor.make {
                    $0.size.equalTo(size)
                }
            }

            let scale: CGFloat = 0.15
            $0.image = UIImage()
            let inset = size * scale
            $0.imageView?.cornerRadius = (size - inset * 2) / 2

            $0.imageView?.anchor.make {
                $0.edges.equalToSuperview().inset(inset)
            }

            $0.didSelect { sender in
                sender.imageView?.backgroundColor = sender.isSelected ? selectedColor : .clear
            }
            configure($0, id)
        }
    }
}
