//
// [WIP] Marin Todorov, https://github.com/icanzilb
//

import RxSwift
import RxCocoa

/**
 * enumeration of animation types:
 * - `animation` uses `UIView.animate(duration:delay:options ...`
 * - `transition` uses `UIView.transition(with:....`
 * - `spring` uses `UIView.animate(duration:delay:options ...` with spring parameters
 */
public enum RxAnimationType {
    case animation
    case transition(UIViewAnimationOptions)
    case spring(damping: CGFloat, velocity: CGFloat)
}

/// data type describing an animation to execute at a later point
public struct AnimationType<Base> {
    let type: RxAnimationType
    let duration: TimeInterval
    let options: UIViewAnimationOptions

    let setup: ((UIView)->Void)?
    let animations: ((UIView)->Void)?
    let completion: ((Bool)->Void)?

    init(type: RxAnimationType, duration: TimeInterval, options: UIViewAnimationOptions = [], setup: ((UIView)->Void)? = nil, animations: ((UIView)->Void)?, completion: ((Bool)->Void)? = nil) {
        self.type = type
        self.duration = duration
        self.options = options
        self.setup = setup
        self.animations = animations
        self.completion = completion
    }

    func animate(view: UIView, block: (()->Void)?) {
        setup?(view)

        DispatchQueue.main.async {
            switch self.type {
            case .animation:
                UIView.animate(withDuration: self.duration, delay: 0, options: self.options, animations: {
                    self.animations?(view)
                    block?()
                }, completion: self.completion)
            case .transition(let type):
                UIView.transition(with: view, duration: self.duration, options: self.options.union(type), animations: {
                    self.animations?(view)
                    block?()
                }, completion: self.completion)
            case .spring(let damping, let velocity):
                UIView.animate(withDuration: self.duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: self.options, animations: {
                    self.animations?(view)
                    block?()
                }, completion: self.completion)
            }
        }
    }
}

/**
 * utility type, offering built-in binding animations, 
 * which you can extend with your own effects as well
 */

/// adds animated bindings to view classes
extension Reactive where Base: UIView {
    public var animated: AnimatedSink<Base> {
        return AnimatedSink<Base>(base: self.base)
    }
}

public struct AnimatedSink<Base> {
    fileprivate var type: AnimationType<Base>!
    fileprivate var base: Base
    init(base: Base, type: AnimationType<Base>? = nil) {
        self.base = base
        self.type = type
    }
}

// MARK: - built-in animated binding sink properties

/// animated `isHidden` sink on `UIView`
extension AnimatedSink where Base: UIView {
    public var isHidden: Binder<Bool> {
        let animation = self.type!
        return Binder(self.base) { view, hidden in
            animation.animate(view: view, block: {
                view.isHidden = hidden
            })
        }
    }
}

/// animated `alpha` sink on `UIView`
extension AnimatedSink where Base: UIView {
    public var alpha: Binder<CGFloat> {
        let animation = self.type!
        return Binder(self.base) { view, alpha in
            animation.animate(view: view, block: {
                view.alpha = alpha
            })
        }
    }
}

/// animated `text` sink binding property on `UILabel`
extension AnimatedSink where Base: UILabel {
    public var text: Binder<String> {
        let animation = self.type!
        return Binder(self.base) { label, text in
            animation.animate(view: label, block: {
                guard let label = label as? UILabel else { return }
                label.text = text
            })
        }
    }
}

/// animated `image` binding sink on `UIImageView`
extension AnimatedSink where Base: UIImageView {
    public var image: Binder<UIImage?> {
        let animation = self.type!
        return Binder(self.base) { imageView, image in
            animation.animate(view: imageView, block: {
                guard let imageView = imageView as? UIImageView else { return }
                imageView.image = image
            })
        }
    }
}

// MARK: - built-in animations

/// cross-dissolve animation on `UIView`
extension AnimatedSink where Base: UIView {
    public func fade(duration: TimeInterval) -> AnimatedSink<Base> {
        let type = AnimationType<Base>(type: RxAnimationType.transition(.transitionCrossDissolve), duration: duration, animations: nil)
        return AnimatedSink<Base>(base: self.base, type: type)
    }
}

/// custom flip direction enum
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

/// flip animation on `UIView`
extension AnimatedSink where Base: UIView {
    public func flip(_ direction: FlipDirection, duration: TimeInterval) -> AnimatedSink<Base> {
        let type = AnimationType<Base>(type: RxAnimationType.transition(direction.viewTransition), duration: duration, animations: nil)
        return AnimatedSink<Base>(base: self.base, type: type)
    }
}


/// example of extending RxAnimated with a custom animation
extension AnimatedSink where Base: UIView {
    public func tick(_ direction: FlipDirection = .right, duration: TimeInterval) -> AnimatedSink<Base> {
        let type = AnimationType<Base>(type: RxAnimationType.spring(damping: 0.33, velocity: 0), duration: duration, setup: { view in
            view.alpha = 0
            view.transform = CGAffineTransform(rotationAngle: direction == .right ?  -0.3 : 0.3)
        }, animations: { view in
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        })
        return AnimatedSink<Base>(base: self.base, type: type)
    }
}
