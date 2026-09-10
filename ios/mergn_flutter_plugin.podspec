#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mergn_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mergn_flutter_plugin'
  s.version          = '3.0.0-beta.1'
  s.summary          = 'Mergn Flutter Plugin'
  s.description      = <<-DESC
Mergn Flutter Plugin
                       DESC
  s.homepage         = 'https://mergn.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mergn' => 'dev@mergn.com' }
  s.source           = { :path => '.' }
  # The plugin itself is just the method-channel bridge; all SDK behaviour lives
  # in the prebuilt native mergn_ios framework, which the bridge re-exports.
  s.source_files = 'mergn_flutter_plugin/Sources/mergn_flutter_plugin/**/*.swift'
  s.vendored_frameworks = 'mergn_flutter_plugin/Frameworks/mergn_ios.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.swift_version = '5.0'
end
