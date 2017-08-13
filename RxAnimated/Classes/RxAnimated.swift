//
// [WIP]
//

import RxSwift
import RxCocoa

public enum FlipDirection {
    case left, right, top, bottom

    var viewTransition: UIViewAnimationOptions {
        switch self {
        case .left: return .transitionFlipFromLeft
        case .right: return .transitionFlipFromRight
        case .top: return .transitionFlipFromTop
        case .bottom: return .transitionFlipFromBottom
        }
    }
}

public enum AnimationType {
    case flip(FlipDirection, TimeInterval)
    case fade(TimeInterval)
    case `default`(duration: TimeInterval, options: UIViewAnimationOptions)
}

public struct AnimatedBinding<Base> {
    fileprivate var base: Base
    fileprivate var type: AnimationType

    init(_ type: AnimationType, base: Base) {
        self.base = base
        self.type = type
    }

    init(duration: TimeInterval, options: UIViewAnimationOptions, base: Base) {
        self.init(.default(duration: duration, options: options), base: base)
    }
}

extension AnimatedBinding where Base: UIView {
    public var alpha: UIBindingObserver<Base, CGFloat> {
        let type = self.type

        return UIBindingObserver(UIElement: self.base) { view, alpha in
            switch type {
            case .flip(let direction, let duration):
                UIView.transition(with: view, duration: duration, options: direction.viewTransition, animations: {
                    view.alpha = alpha
                }, completion: nil)
            case .fade(let duration):
                UIView.animate(withDuration: duration, delay: 0.0, options: [], animations: {
                    view.alpha = alpha
                }, completion: nil)
            case .default(let duration, let options):
                UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                    view.alpha = alpha
                }, completion: nil)
            }
        }
    }

    public var isHidden: UIBindingObserver<Base, Bool> {
        let type = self.type

        return UIBindingObserver(UIElement: self.base) { view, hidden in
            switch type {
            case .flip(let direction, let duration):
                UIView.transition(with: view, duration: duration, options: direction.viewTransition, animations: {
                    view.isHidden = hidden
                }, completion: nil)
            case .fade(let duration):
                UIView.transition(with: view, duration: duration, options: [.transitionCrossDissolve], animations: {
                    view.isHidden = hidden
                }, completion: nil)
            case .default(let duration, let options):
                UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                    view.alpha = hidden ? 0.0 : 1.0
                }, completion: nil)
            }
        }
    }
}

extension AnimatedBinding where Base: UILabel {
    public var text: UIBindingObserver<Base, String> {
        let type = self.type

        return UIBindingObserver(UIElement: self.base) { label, text in
            switch type {
            case .flip(let direction, let duration):
                UIView.transition(with: label, duration: duration, options: [direction.viewTransition, UIViewAnimationOptions.allowAnimatedContent], animations: {
                    label.text = text
                }, completion: nil)
            case .fade(let duration):
                UIView.transition(with: label, duration: duration, options: [UIViewAnimationOptions.transitionCrossDissolve, UIViewAnimationOptions.allowAnimatedContent], animations: {
                    label.text = text
                }, completion: nil)
            case .default(let duration, let options):
                UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                    label.text = text
                }, completion: nil)
            }
        }
    }
}

extension AnimatedBinding where Base: UIImageView {
    public var image: UIBindingObserver<Base, UIImage> {
        let type = self.type

        return UIBindingObserver(UIElement: self.base) { view, image in
            switch type {
            case .flip(let direction, let duration):
                UIView.transition(with: view, duration: duration, options: direction.viewTransition, animations: {
                    view.image = image
                }, completion: nil)
            case .fade(let duration):
                UIView.transition(with: view, duration: duration, options: [.transitionCrossDissolve], animations: {
                    view.image = image
                }, completion: nil)
            case .default(let duration, let options):
                UIView.transition(with: view, duration: duration, options: options.union([.transitionCrossDissolve]), animations: {
                    view.image = image
                }, completion: nil)
            }
        }
    }
}

extension Reactive where Base: UIView {
    public func animated(duration: TimeInterval, options: UIViewAnimationOptions) -> AnimatedBinding<Base> {
        return AnimatedBinding(duration: duration, options: options, base: base)
    }

    public func animated(_ type: AnimationType) -> AnimatedBinding<Base> {
        return AnimatedBinding(type, base: base)
    }
}
