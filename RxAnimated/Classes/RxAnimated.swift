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

enum RxAnimationType {
    case animation, transition(UIViewAnimationOptions), spring(damping: CGFloat, velocity: CGFloat)
}

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

extension AnimationType where Base: UILabel {
    public static func fade(duration: TimeInterval) -> AnimationType {
        return AnimationType(type: .transition(.transitionCrossDissolve), duration: duration, animations: nil)
    }
}

extension AnimationType where Base: UILabel {
    public static func flip(_ direction: FlipDirection, duration: TimeInterval) -> AnimationType {
        return AnimationType(type: .transition(direction.viewTransition), duration: duration, animations: nil)
    }
}

public struct AnimatedBinding<Base> {
    fileprivate var base: Base
    fileprivate var type: AnimationType<Base>

    init(_ type: AnimationType<Base>, base: Base) {
        self.base = base
        self.type = type
    }
}

extension AnimatedBinding where Base: UILabel {
    public var text: UIBindingObserver<Base, String> {
        let animation = self.type

        return UIBindingObserver(UIElement: self.base) { label, text in
            animation.animate(view: label, block: {
                label.text = text
            })
        }
    }
}

/*
 * WIP: Proposal for extensible animation interface
 *
 * This is an example of adding a new binding animation for
 * a specific view and property:
 *
 */

extension AnimatedBinding where Base: UIImageView {

    // here we add a new animated sink to UIImageView
    // no need to do that if it's already added, like for UILabel.text

    public var image: UIBindingObserver<Base, UIImage?> {
        let animation = self.type

        return UIBindingObserver(UIElement: self.base) { imageView, image in
            animation.animate(view: imageView, block: {
                imageView.image = image
            })
        }
    }
}

extension AnimationType where Base: UIImageView {

    // here we add a new type of animation for the given view 
    // you can add as many as you want

    public static func flip(_ direction: FlipDirection, duration: TimeInterval) -> AnimationType {
        return AnimationType(type: .spring(damping: 0.33, velocity: 0), duration: duration, setup: { view in
            view.alpha = 0
            view.transform = CGAffineTransform(rotationAngle: -0.15)
        }, animations: { view in
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        })
    }
}

/*
 here's how you invoke the new animation on that new property

 Observable.from(newImage)
   .bind(to: myImageView.rx.animated(.flip(.top, duration: 0.25)).image)

*/

/*
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
*/
extension Reactive where Base: UIView {
    public func animated(_ type: AnimationType<Base>) -> AnimatedBinding<Base> {
        return AnimatedBinding(type, base: base)
    }
}
