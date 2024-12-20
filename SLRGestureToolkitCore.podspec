#
# Be sure to run `pod lib lint SLRGestureToolkitCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SLRGestureToolkitCore'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SLRGestureToolkitCore.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Accessible-Technology-in-Sign/SLRGestureToolkitCore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'eshwavin@gmail.com' => 'eshwavin@gmail.com' }
  s.source           = { :git => 'https://github.com/Accessible-Technology-in-Sign/SLRGestureToolkitCore', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  
  s.dependency 'MediaPipeTasksVision', '~> 0.10.14'
  s.dependency 'TensorFlowLiteSwift'

  s.source_files = "SLRGestureToolkitCore/Source/**/*"
  
   s.resource_bundles = {
     'SLRGestureToolkitCore' => ['SLRGestureToolkitCore/Source/MLAssets/*']
   }
   
   s.resources = 'SLRGestureToolkitCore/Source/MLAssets/*'

end
