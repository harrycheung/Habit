source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'KAProgressLabel'
pod 'FontAwesome.swift'

def testing_pods
  pod 'Nimble'
end

target 'HabitTests', :exclusive => true do
  testing_pods
end

target 'HabitUITests', :exclusive => true do
  testing_pods
end