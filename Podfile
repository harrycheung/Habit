
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

target 'Habit' do
  project 'Habit'

  pod 'KAProgressLabel'
  pod 'FontAwesome.swift', :git => 'https://github.com/thii/FontAwesome.swift.git', :branch => 'swift-4.0'

  target 'HabitTests' do
    inherit! :search_paths
  end

  target 'HabitUITests' do
    inherit! :search_paths
  end
end
