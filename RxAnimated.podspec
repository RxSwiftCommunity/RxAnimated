Pod::Spec.new do |s|
  s.name             = 'RxAnimated'
  s.version          = '0.9.0'
  s.summary          = 'Animated bindings for RxSwift/RxCocoa'

  s.description      = <<-DESC
  	Allows developers to bind observables to properties and animate any values changes in a clear and semantic way.
    The library includes a set of basic animations and allows for easy extending with further effects.
                       DESC

  s.homepage         = 'https://github.com/RxSwiftCommunity/RxAnimated'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'icanzilb' => 'marin@underplot.com' }
  s.source           = { :git => 'https://github.com/RxSwiftCommunity/RxAnimated.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '10.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    s.source_files = 'Sources/RxAnimated/**/*.{swift}'
  end

#  s.subspec 'Animations' do |cs|
#    s.source_files = 'RxAnimated/Animations/*'
#  end

  s.frameworks = 'UIKit'
  s.dependency 'RxSwift', '~> 6.0'
  s.dependency 'RxCocoa', '~> 6.0'

  s.swift_version = "5.2"

end
