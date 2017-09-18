# [WIP] RxAnimated

[![CI Status](http://img.shields.io/travis/icanzilb/RxAnimated.svg?style=flat)](https://travis-ci.org/icanzilb/RxAnimated)
[![Version](https://img.shields.io/cocoapods/v/RxAnimated.svg?style=flat)](http://cocoapods.org/pods/RxAnimated)
[![License](https://img.shields.io/cocoapods/l/RxAnimated.svg?style=flat)](http://cocoapods.org/pods/RxAnimated)
[![Platform](https://img.shields.io/cocoapods/p/RxAnimated.svg?style=flat)](http://cocoapods.org/pods/RxAnimated)

> **NB:** This is a pre-release software, currently the lib works with Xcode9 GM and RxSwift4 beta.0 - and Xcode doesn't offer autocomplete when you use it.


**RxAnimated** provides animation interface to RxCocoa's bindings.

It comes with few predefined animation bindings, and provides a flexible mechanism for you to add your own predefined animations and use them when binding with RxCocoa.

## Usage

### Built-in animations

When binding values with RxCocoa you write something like:

```swift
textObservable
  .bind(to: labelFlip.rx.text)
```

![](etc/label-noanim.gif)

This updates the label's text each time the observable emits a new string value. But this happens abruptly and without any transition. With RxAnimated you can use the `animated` extension to **bind values with animations**, like so:

```swift
textObservable
  .bind(to: labelFlip.rx.animated.flip(.top, duration: 0.33).text)
```

![](etc/label-anim.gif)

The same built-in fade and flip animations work on any `UIView` element. And also on specific properties like `text` for `UILabel` or `image` on `UIImageView`.

### Custom animations

You can easily add your custom bind animations to match the visual style of your app.

I. (Optional) If you are animating a new binding sink that has no animated binding (e.g. `UIImageView.rx.image`, `UILabel.rx.text` and more are already included but you need another property)


```swift
// This is your class `UILabel`
extension AnimatedSink where Base: UILabel { 
    // This is your property name `text` and value type `String`
    public var text: Binder<String> { 
        let animation = self.type!
        return Binder(self.base) { label, text in
            animation.animate(view: label, block: {
                guard let label = label as? UILabel else { return }
                // Here you update the property
                label.text = text 
            })
        }
    }
}
```

II. Add your new animation method:

```swift
// This is your class `UIView`
extension AnimatedSink where Base: UIView { 
    // This is your animation name `tick`
    public func tick(_ direction: FlipDirection = .right, duration: TimeInterval) -> AnimatedSink<Base> { 
        // use one of the animation types and provide `setup` and `animation` blocks
        let type = AnimationType<Base>(type: RxAnimationType.spring(damping: 0.33, velocity: 0), duration: duration, setup: { view in
            view.alpha = 0
            view.transform = CGAffineTransform(rotationAngle: direction == .right ?  -0.3 : 0.3)
        }, animations: { view in
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        })
        
        //return AnimatedSink
        return AnimatedSink<Base>(base: self.base, type: type) 
    }
}
```

III. Now you can use your new animation to bind subscriptions, instead of `rx.text` use `rx.animated.tick(.left, duration: 0.75).text` providing the orientation you want `.left` or `.right` and a duration:

```swift
textObservable
    .bind(to: labelCustom.rx.animated.tick(.left, duration: 0.75).text)
```

## Example

The demo app shows few animations in action, download the repo and give it a try.

## Requirements

> !! RxSwift 4 beta.0

## Installation

RxAnimated is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RxAnimated"
```

## Author

Marin Todorov, https://github.com/icanzilb

## License

RxAnimated is available under the MIT license. See the LICENSE file for more info.
