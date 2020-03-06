import RxSwift
import RxCocoa
import UIKit

public struct RxAnimated {
    public static let areAnimationsEnabled = BehaviorRelay(value: true)
    fileprivate static var areDefaultHeuristicsEnabled = false
    public static func enableDefaultPerformanceHeuristics() {
        areDefaultHeuristicsEnabled = true
    }
}

// MARK: - basic animation types

/**
 * enumeration of animation types:
 * - `animation` uses `UIView.animate(duration:delay:options ...`
 * - `transition` uses `UIView.transition(with:....`
 * - `spring` uses `UIView.animate(duration:delay:options ...` with spring parameters
 */
public enum RxAnimationType {
    case animation
    case transition(UIView.AnimationOptions)
    case spring(damping: CGFloat, velocity: CGFloat)
}

// MARK: - animation future

/// data type describing an animation to execute at a later point
public struct AnimationType<Base> {
    let type: RxAnimationType
    let duration: TimeInterval

    let options: UIView.AnimationOptions

    let setup: ((UIView) -> Void)?
    let animations: ((UIView) -> Void)?
    let completion: ((Bool) -> Void)?

    /**
     * creates an animation "future"
     * - parameter type: animation type; spring, transition, standard
     * - parameter duration: animation duration
     * - parameter options: animation options
     * - parameter setup: block of setup code to be executed before animation starts
     * - parameter animations: block of code to be executed during animation
     * - parameter completion: block of code to be executed after the animation has finished
     */
    public init(type: RxAnimationType, duration: TimeInterval, options: UIView.AnimationOptions = [], setup: ((UIView)->Void)? = nil, animations: ((UIView) -> Void)?, completion: ((Bool) -> Void)? = nil) {
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
    public func animate(view: UIView, binding: (() -> Void)?) {
        setup?(view)

        DispatchQueue.main.async {
            if (RxAnimated.areDefaultHeuristicsEnabled && self.shouldDisableAnimationsViaDefaultHeuristics) || !RxAnimated.areAnimationsEnabled.value {
                binding?()
                self.animations?(view)
                return
            }

            switch self.type {
            case .animation:
                UIView.animate(withDuration: self.duration, delay: 0, options: self.options, animations: {
                    binding?()
                    self.animations?(view)
                }, completion: self.completion)
            case .transition(let type):
                UIView.transition(with: view, duration: self.duration, options: self.options.union(type), animations: {
                    binding?()
                    self.animations?(view)
                }, completion: self.completion)
            case .spring(let damping, let velocity):
                UIView.animate(withDuration: self.duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: self.options, animations: {
                    binding?()
                    self.animations?(view)
                }, completion: self.completion)
            }
        }
    }

    private var shouldDisableAnimationsViaDefaultHeuristics: Bool {
        if #available(iOS 11, tvOS 11, *) {
            return ProcessInfo.processInfo.isLowPowerModeEnabled
                || ProcessInfo.processInfo.thermalState == .serious
                || ProcessInfo.processInfo.thermalState == .critical
                || UIAccessibility.isReduceMotionEnabled
        } else {
            return ProcessInfo.processInfo.isLowPowerModeEnabled
                || UIAccessibility.isReduceMotionEnabled
        }
    }
  
}



// MARK: - animated reactive extensions

extension Observable {
    /// `bind(to:)` alias to use with animated bindings
    public func bind(animated observer: Binder<Element>) -> Disposable {
        return self.subscribe(observer)
    }
}

extension SharedSequence {
    /// `bind(to:)` alias to use with animated bindings
    public func bind(animated observer: Binder<Element>) -> Disposable {
        return self.asObservable().subscribe(observer)
    }
}

/// an animations proxy data type
public struct AnimatedSink<Base> {
    public var type: AnimationType<Base>!
    public var base: Base

    /**
     * - parameter base: base class of this animation sink (UIView, UILabel, etc)
     * - parameter type: an animation future to be executed when the binding recieves an element
     */
    public init(base: Base, type: AnimationType<Base>? = nil) {
        self.base = base
        self.type = type
    }
}
