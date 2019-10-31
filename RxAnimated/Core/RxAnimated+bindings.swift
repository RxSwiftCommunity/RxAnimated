import RxSwift
import RxCocoa

// MARK: - Reactive ext on UIView

extension Reactive where Base: UIView {
    /// adds animated bindings to view classes under `rx.animated`
    public var animated: AnimatedSink<Base> {
        return AnimatedSink<Base>(base: self.base)
    }
}

extension AnimatedSink {
    public var lazy: AnimatedSink {
        return AnimatedSink(base: self.base, type: self.type.lazy)
    }
}

extension AnimatedSink where Base: UIView {
    public func bind<T>(with animation: @escaping ((Base, T)  -> Void)) -> Binder<T> {
        var mutableSelf = self
        return Binder(mutableSelf.base) { view, value in
            mutableSelf.type.lazyAnimate(view: view) {
                animation(view, value)
            }
        }
    }
}

// MARK: - UIView
extension AnimatedSink where Base: UIView {
    public var isHidden: Binder<Bool> {
        return bind { view, hidden in
            view.isHidden = hidden
        }
    }
}

extension AnimatedSink where Base: UIView {
    public var alpha: Binder<CGFloat> {
        return bind { view, alpha in
            view.alpha = alpha
        }
    }
}

// MARK: - UILabel
extension AnimatedSink where Base: UILabel {
    public var text: Binder<String> {
        return bind { label, text in
            (label as UILabel).text = text
        }
    }
    public var attributedText: Binder<NSAttributedString> {
        return bind { label, text in
            (label as UILabel).attributedText = text
        }
    }
}

// MARK: - UIControl
extension AnimatedSink where Base: UIControl {
    public var isEnabled: Binder<Bool> {
        return bind { control, enabled in
            (control as UIControl).isEnabled = enabled
        }
    }

    public var isSelected: Binder<Bool> {
        return bind { control, selected in
            (control as UIControl).isSelected = selected
        }
    }
}

// MARK: - UIButton
extension AnimatedSink where Base: UIButton {
    public var title: Binder<String> {
        return bind { button, title in
            (button as UIButton).setTitle(title, for: button.state)
        }
    }
    public var image: Binder<UIImage?> {
        return bind { button, image in
            (button as UIButton).setImage(image, for: button.state)
        }
    }
    public var backgroundImage: Binder<UIImage?> {
        return bind { button, image in
            (button as UIButton).setBackgroundImage(image, for: button.state)
        }
    }
}

// MARK: - UIImageView
extension AnimatedSink where Base: UIImageView {
    public var image: Binder<UIImage?> {
        return bind { imageView, image in
            (imageView as UIImageView).image = image
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
    
    public func bind<T>(with animation: @escaping ((NSLayoutConstraint, T)  -> Void)) -> Binder<T> {
        var mutableSelf = self
        return Binder(mutableSelf.base) { constraint, value in
            guard let view = constraint.firstItem as? UIView,
                let superview = view.superview else { return }
            mutableSelf.type.lazyAnimate(view: superview) {
                animation(constraint, value)
            }
        }
    }

    public var constant: Binder<CGFloat> {
        return bind { constraint, constant in
            constraint.constant = constant
        }
    }

    public var isActive: Binder<Bool> {
        return bind { constraint, active in
            constraint.isActive = active
        }
    }
}
