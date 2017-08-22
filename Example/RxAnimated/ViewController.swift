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

    @IBOutlet var imageAlpha: UIImageView!
    @IBOutlet var imageIsHidden: UIImageView!

    private let timer = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance).shareReplay(1)
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // VALUE CHANGES

        timer
            .map { "label fade [\($0)]" }
            .bind(to: labelFade.rx.animated.fade(duration: 0.5).text )
            .disposed(by: bag)
/*
        timer
            .scan("adorable1") { _, count in
                return count % 2 == 0 ? "adorable1" : "adorable2"
            }
            .map { name in
                return UIImage(named: name)!
            }
            .bind(to: imageFlip.rx.animated(.tick(.right, duration: 1.0)).image)
            .disposed(by: bag)

        timer
            .delay(0.33, scheduler: MainScheduler.instance)
            .map { "label flip top [\($0)]" }
            .debug()
            .bind(to: labelFlip.rx.animated(.flip(.top, duration: 0.33)).text)
            .disposed(by: bag)

        timer
            .delay(0.67, scheduler: MainScheduler.instance)
            .map { "label flip left [\($0)]" }
            .bind(to: labelCustom.rx.animated(.flip(.left, duration: 0.33)).text)
            .disposed(by: bag)

        timer
            .scan("adorable1") { _, count in
                return count % 2 == 0 ? "adorable1" : "adorable2"
            }
            .map { name in
                return UIImage(named: name)!
            }
            .bind(to: imageFlip.rx.animated(.flip(.right, duration: 0.33)).image)
            .disposed(by: bag)

        // PROPERTIES

        timer
            .scan(0) { _, count in
                return count % 2 == 0 ? 1 : 0
            }
            .bind(to: imageAlpha.rx.animated(.).alpha)
            .disposed(by: bag)

        timer
            .scan(false) { _, count in
                return count % 2 == 0 ? true : false
            }
            .bind(to: imageIsHidden.rx.animated(.flip(.bottom, 0.45)).isHidden)
            .disposed(by: bag)

         */
    }

}

