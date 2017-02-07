#
# Be sure to run `pod lib lint ExhibitionSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ExhibitionSwift'
  s.version          = '0.1.2'
  s.summary          = 'Exhibition is a mutable asynchronous image gallery that makes no assumptions.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Exhibition is a mutable asynchronous image gallery that makes no assumptions. Exhibition does not assume what you want to do you with your image gallery but instead extends to you full and easy control mechanisms. Load an image from disk or remote url, add and delete images at will. Customize the UI.'

  s.homepage         = 'https://github.com/eligreg/ExhibitionSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eli Gregory' => 'eligreg@gmail.com' }
  s.source           = { :git => 'https://github.com/eligreg/ExhibitionSwift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ExhibitionSwift/Classes/**/*'

  s.resource_bundles = {
    'ExhibitionSwift' => ['ExhibitionSwift/Assets/*.xcassets']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
