source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'SnapKit'
pod 'KAProgressLabel'
pod 'FontAwesome.swift'

def testing_pods
  pod 'Nimble', '2.0.0'
end

target 'HabitTests', :exclusive => true do
  testing_pods
end

target 'HabitUITests', :exclusive => true do
  testing_pods
end