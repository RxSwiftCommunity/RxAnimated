//
// Marin Todorov, https://github.com/icanzilb
//

import RxSwift
import RxCocoa

// MARK: - UIView
extension AnimatedSink where Base: UIView {
    public var isHidden: Binder<Bool> {
        return Binder(self.base) { view, hidden in
            self.type.animate(view: view, block: {
                view.isHidden = hidden
            })
        }
    }
}

extension AnimatedSink where Base: UIView {
    public var alpha: Binder<CGFloat> {
        return Binder(self.base) { view, alpha in
            self.type.animate(view: view, block: {
                view.alpha = alpha
            })
        }
    }
}

// MARK: - UILabel
extension AnimatedSink where Base: UILabel {
    public var text: Binder<String> {
        return Binder(self.base) { label, text in
            self.type.animate(view: label, block: {
                guard let label = label as? UILabel else { return }
                label.text = text
            })
        }
    }
    public var attributedText: Binder<NSAttributedString> {
        return Binder(self.base) { label, text in
            self.type.animate(view: label, block: {
                guard let label = label as? UILabel else { return }
                label.attributedText = text
            })
        }
    }
}

// MARK: - UIControl
extension AnimatedSink where Base: UIControl {
    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { control, enabled in
            self.type.animate(view: control, block: {
                guard let control = control as? UIControl else { return }
                control.isEnabled = enabled
            })
        }
    }
    public var isSelected: Binder<Bool> {
        return Binder(self.base) { control, selected in
            self.type.animate(view: control, block: {
                guard let control = control as? UIControl else { return }
                control.isSelected = selected
            })
        }
    }
}

// MARK: - UIButton
extension AnimatedSink where Base: UIButton {
    public var title: Binder<String> {
        return Binder(self.base) { button, title in
            self.type.animate(view: button, block: {
                guard let button = button as? UIButton else { return }
                button.setTitle(title, for: button.state)
            })
        }
    }
    public var image: Binder<UIImage?> {
        return Binder(self.base) { button, image in
            self.type.animate(view: button, block: {
                guard let button = button as? UIButton else { return }
                button.setImage(image, for: button.state)
            })
        }
    }
    public var backgroundImage: Binder<UIImage?> {
        return Binder(self.base) { button, image in
            self.type.animate(view: button, block: {
                guard let button = button as? UIButton else { return }
                button.setBackgroundImage(image, for: button.state)
            })
        }
    }
}

// MARK: - UIImageView
extension AnimatedSink where Base: UIImageView {
    public var image: Binder<UIImage?> {
        return Binder(self.base) { imageView, image in
            self.type.animate(view: imageView, block: {
                guard let imageView = imageView as? UIImageView else { return }
                imageView.image = image
            })
        }
    }
}

// MARK: - NSLayoutConstraint

// TODO: test this in the demo app

extension AnimatedSink where Base: NSLayoutConstraint {
    public var constant: Binder<CGFloat> {
        return Binder(self.base) { constraint, constant in
            guard let view = constraint.firstItem as? UIView,
                let superview = view.superview else { return }

            self.type.animate(view: superview, block: {
                constraint.constant = constant
            })
        }
    }
    public var isActive: Binder<Bool> {
        return Binder(self.base) { constraint, active in
            guard let view = constraint.firstItem as? UIView,
                let superview = view.superview else { return }

            self.type.animate(view: superview, block: {
                constraint.isActive = active
            })
        }
    }
}

