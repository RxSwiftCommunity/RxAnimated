//
// Marin Todorov, https://github.com/icanzilb
//

import RxSwift
import RxCocoa

// MARK: - basic animation types

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

// MARK: - animation future

/// data type describing an animation to execute at a later point
public struct AnimationType<Base> {
    let type: RxAnimationType
    let duration: TimeInterval
    let options: UIViewAnimationOptions

    let setup: ((UIView)->Void)?
    let animations: ((UIView)->Void)?
    let completion: ((Bool)->Void)?

    /**
     * creates an animation "future"
     * - parameter type: animation type; spring, transition, standard
     * - parameter duration: animation duration
     * - parameter options: animation options
     * - parameter setup: block of setup code to be executed before animation starts
     * - parameter animations: block of code to be executed during animation
     * - parameter completion: block of code to be executed after the animation has finished
     */
    init(type: RxAnimationType, duration: TimeInterval, options: UIViewAnimationOptions = [], setup: ((UIView)->Void)? = nil, animations: ((UIView)->Void)?, completion: ((Bool)->Void)? = nil) {
        self.type = type
        self.duration = duration
        self.options = options
        self.setup = setup
        self.animations = animations
        self.completion = completion
    }

    /**
     * executes the setup -> animations -> block -> completion blocks chain
     * - parameter view: a view to run the animations on
     * - parameter block: a custom block to inject inside the animation
     */
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

// MARK: - animated reactive extensions

extension Observable {
    /// `bind(to:)` alias to use with animated bindings
    public func bind(animated observer: Binder<E>) -> Disposable {
        return self.subscribe(observer)
    }
}

extension SharedSequence {
    /// `bind(to:)` alias to use with animated bindings
    public func bind(animated observer: Binder<E>) -> Disposable {
        return self.asObservable().subscribe(observer)
    }
}

extension Reactive where Base: UIView {
    /// adds animated bindings to view classes under `rx.animated`
    public var animated: AnimatedSink<Base> {
        return AnimatedSink<Base>(base: self.base)
    }
}

/// an animations proxy data type
public struct AnimatedSink<Base> {
    internal var type: AnimationType<Base>!
    internal var base: Base

    /**
     * - parameter base: base class of this animation sink (UIView, UILabel, etc)
     * - parameter type: an animation future to be executed when the binding recieves an element
     */
    init(base: Base, type: AnimationType<Base>? = nil) {
        self.base = base
        self.type = type
    }
}
