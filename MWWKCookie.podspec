#
# Be sure to run `pod lib lint MWWKCookie.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MWWKCookie'
  s.version          = '0.0.1'
  s.summary          = 'A WKWebview cookie handler'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A WKWebview cookie handler, Swift version of GGWkCookie
                       DESC

  s.homepage         = 'https://github.com/mokong/MWWKCookie'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'morgan' => 'a525325614@163.com' }
  s.source           = { :git => 'https://github.com/mokong/MWWKCookie.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = "5.0"
  s.preserve_paths = "MWWKCookie/*"
  s.source_files = 'MWWKCookie/**/*'
  
  s.resource_bundles = {
    'MWWKCookie' => ['MWWKCookie/Resources/*.{json,xib,jpg,png,webp,db,plist,bundle,gif,sqlite,7z,zip,strings,xcassets,js,html,dat,data,css}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
