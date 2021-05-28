# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

def rxswift
  pod 'RxSwift'
  pod 'RxCocoa'
end

target 'RxSwiftApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

end

target 'Application' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  rxswift

end

target 'Domain' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  rxswift

end

target 'FirebasePlatform' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  rxswift
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'

end
