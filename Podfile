source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'SnapKit', :git => 'https://github.com/SnapKit/SnapKit.git', :branch => 'swift-2.0'
pod 'KAProgressLabel'
pod 'FontAwesome.swift'

def testing_pods
  pod 'Quick', '~> 0.5.0'
  pod 'Nimble', '2.0.0-rc.2'
end

target 'HabitTests' do
  testing_pods
end

target 'HabitUITests' do
  testing_pods
end