import RxSwift
import RxCocoa

// MARK: - Reactive ext on UIView

extension Reactive where Base: UIView {
    /// adds animated bindings to view classes under `rx.animated`
    public var animated: AnimatedSink<Base> {
        return AnimatedSink<Base>(base: self.base)
    }
}

// MARK: - UIView
extension AnimatedSink where Base: UIView {
    public var isHidden: Binder<Bool> {
        return Binder(self.base) { view, hidden in
            self.type.animate(view: view) {
                view.isHidden = hidden
            }
        }
    }
}

extension AnimatedSink where Base: UIView {
    public var alpha: Binder<CGFloat> {
        return Binder(self.base) { view, alpha in
            self.type.animate(view: view) {
                view.alpha = alpha
            }
        }
    }
}

// MARK: - UILabel
extension AnimatedSink where Base: UILabel {
    public var text: Binder<String> {
        return Binder(self.base) { label, text in
            self.type.animate(view: label) {
                guard let label = label as? UILabel else { return }
                label.text = text
            }
        }
    }
    public var attributedText: Binder<NSAttributedString> {
        return Binder(self.base) { label, text in
            self.type.animate(view: label) {
                guard let label = label as? UILabel else { return }
                label.attributedText = text
            }
        }
    }
}

// MARK: - UIControl
extension AnimatedSink where Base: UIControl {
    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { control, enabled in
            self.type.animate(view: control) {
                guard let control = control as? UIControl else { return }
                control.isEnabled = enabled
            }
        }
    }
    public var isSelected: Binder<Bool> {
        return Binder(self.base) { control, selected in
            self.type.animate(view: control) {
                guard let control = control as? UIControl else { return }
                control.isSelected = selected
            }
        }
    }
}

// MARK: - UIButton
extension AnimatedSink where Base: UIButton {
    public var title: Binder<String> {
        return Binder(self.base) { button, title in
            self.type.animate(view: button) {
                guard let button = button as? UIButton else { return }
                button.setTitle(title, for: button.state)
            }
        }
    }
    public var image: Binder<UIImage?> {
        return Binder(self.base) { button, image in
            self.type.animate(view: button) {
                guard let button = button as? UIButton else { return }
                button.setImage(image, for: button.state)
            }
        }
    }
    public var backgroundImage: Binder<UIImage?> {
        return Binder(self.base) { button, image in
            self.type.animate(view: button) {
                guard let button = button as? UIButton else { return }
                button.setBackgroundImage(image, for: button.state)
            }
        }
    }
}

// MARK: - UIImageView
extension AnimatedSink where Base: UIImageView {
    public var image: Binder<UIImage?> {
        return Binder(self.base) { imageView, image in
            self.type.animate(view: imageView) {
                guard let imageView = imageView as? UIImageView else { return }
                imageView.image = image
            }
        }
    }
}

// MARK: - Reactive ext on NSLayoutConstraint
extension Reactive where Base: NSLayoutConstraint {
    /// adds animated bindings to view classes under `rx.animated`
    public var animated: AnimatedSink<Base> {
        return AnimatedSink<Base>(base: self.base)
    }
}

// MARK: - NSLayoutConstraint
extension AnimatedSink where Base: NSLayoutConstraint {
    public var constant: Binder<CGFloat> {
        return Binder(self.base) { constraint, constant in
            guard let view = constraint.firstItem as? UIView,
                let superview = view.superview else { return }

            self.type.animate(view: superview) {
                constraint.constant = constant
            }
        }
    }
    public var isActive: Binder<Bool> {
        return Binder(self.base) { constraint, active in
            guard let view = constraint.firstItem as? UIView,
                let superview = view.superview else { return }

            self.type.animate(view: superview) {
                constraint.isActive = active
            }
        }
    }
}
