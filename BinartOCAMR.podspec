#
# Be sure to run `pod lib lint BinartOCAMR.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BinartOCAMR'
  s.version          = '0.1.3'
  s.summary          = 'TSVoiceConverter-s Objective-C version.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  TSVoiceConverter-s Objective-C version. no more message.
                       DESC

  s.homepage         = 'https://github.com/fallending/BinartOCAMR-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fallen ink' => 'fengzilijie@qq.com' }
  s.source           = { :git => 'https://github.com/fallending/BinartOCAMR-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  
  # Xcode 12, pod lib lint, report error:
  # Ld /Users/seven/Library/Developer/Xcode/DerivedData/App-cbdiuiekijjutjfhwopfosntnsnt/Build/Intermediates.noindex/App.build/Release-iphonesimulator/App.build/Objects-normal/arm64/Binary/App normal arm64
  s.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.source_files = [
    'BinartOCAMR/Classes/**/*.{h,mm}',
    'BinartOCAMR/Classes/*.{h,mm}',
    'BinartOCAMR/Classes/**/*.{h,mm,m}'
  ]
  s.vendored_libraries = "BinartOCAMR/Classes/**/*.a"
  
  s.public_header_files = 'BinartOCAMR/Classes/**/*.h'
end
