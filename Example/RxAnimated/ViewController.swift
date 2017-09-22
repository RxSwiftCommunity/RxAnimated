//
//  ViewController.swift
//  RxAnimated
//
//  Created by icanzilb on 08/12/2017.
//  Copyright (c) 2017 icanzilb. All rights reserved.
//

// images from: http://avatars.adorable.io/

import UIKit
import RxSwift
import RxCocoa
import RxAnimated

class ViewController: UIViewController {

    @IBOutlet var labelFade: UILabel!
    @IBOutlet var labelFlip: UILabel!
    @IBOutlet var labelCustom: UILabel!
    @IBOutlet var imageFlip: UIImageView!
    @IBOutlet var imageBlock: UIImageView!
    
    @IBOutlet var labelAlpha: UILabel!
    @IBOutlet var imageAlpha: UIImageView!

    @IBOutlet var labelIsHidden: UILabel!
    @IBOutlet var imageIsHidden: UIImageView!

    @IBOutlet var leftConstraint: NSLayoutConstraint!
    @IBOutlet var rightConstraint: NSLayoutConstraint!

    private let timer = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance).shareReplay(1)
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Animate `text` with a crossfade
        timer
            .map { "Text + fade [\($0)]" }
            .bind(animated: labelFade.rx.animated.fade(duration: 0.33).text)
            .disposed(by: bag)

        // Animate `text` with a top flip
        timer
            .delay(0.33, scheduler: MainScheduler.instance)
            .map { "Text + flip [\($0)]" }
            .bind(animated: labelFlip.rx.animated.flip(.top, duration: 0.33).text)
            .disposed(by: bag)

        // Animate `text` with a custom animation `tick`, as driver
        timer
            .delay(0.67, scheduler: MainScheduler.instance)
            .map { "Text + custom [\($0)]" }
            .asDriver(onErrorJustReturn: "error")
            .bind(animated: labelCustom.rx.animated.tick(.left, duration: 0.75).text)
            .disposed(by: bag)

        // Animate `image` with a custom animation `tick`
        timer
            .scan("adorable1") { _, count in
                return count % 2 == 0 ? "adorable1" : "adorable2"
            }
            .map { name in
                return UIImage(named: name)!
            }
            .bind(animated: imageFlip.rx.animated.tick(.right, duration: 1.0).image)
            .disposed(by: bag)

        var angle: CGFloat = 0.0
        // Animate `image` with a custom block
        timer
            .scan("adorable1") { _, count in
                return count % 2 == 0 ? "adorable1" : "adorable2"
            }
            .map { name in
                return UIImage(named: name)!
            }
            .bind(animated: imageBlock.rx.animated.animation(duration: 0.5, animations: { [weak self] in
                angle += 0.2
                self?.imageBlock.transform = CGAffineTransform(rotationAngle: angle)
            }).image )
            .disposed(by: bag)

        // Animate layout constraint
        timer
            .scan(0) { acc, _ in
                return acc == 0 ? 105 : 0
            }
            .bind(animated: leftConstraint.rx.animated.layout(duration: 0.33).constant )
            .disposed(by: bag)

        // Activate/Deactivate a constraint
        timer
            .scan(true) { acc, _ in
                return !acc
            }
            .bind(animated: rightConstraint.rx.animated.layout(duration: 0.33).isActive )
            .disposed(by: bag)

        // Animate `alpha` with a flip
        let timerAlpha = timer
            .scan(1) { acc, _ in
                return acc > 2 ? 1 : acc + 1
            }
            .map { CGFloat(1.0 / $0 ) }

        timerAlpha
            .bind(animated: imageAlpha.rx.animated.flip(.left, duration: 0.45).alpha)
            .disposed(by: bag)
        timerAlpha
            .map { "alpha: \($0)" }
            .bind(to: labelAlpha.rx.text)
            .disposed(by: bag)

        // Animate `isHidden` with a flip
        let timerHidden = timer
            .scan(false) { _, count in
                return count % 2 == 0 ? true : false
            }

        timerHidden
            .bind(animated: imageIsHidden.rx.animated.flip(.bottom, duration: 0.45).isHidden)
            .disposed(by: bag)
        timerHidden
            .map { "hidden: \($0)" }
            .bind(to: labelIsHidden.rx.text)
            .disposed(by: bag)

        // disable animations when the device is working hard or user is motion sensitive
        RxAnimated.enableDefaultPerformanceHeuristics()

        // disable animations manually
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            RxAnimated.areAnimationsEnabled.value = false
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
            RxAnimated.areAnimationsEnabled.value = true
        })
    }
}
