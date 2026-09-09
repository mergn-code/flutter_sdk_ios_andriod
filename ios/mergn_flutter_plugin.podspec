#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mergn_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mergn_flutter_plugin'
  s.version          = '2.1.3'
  s.summary          = 'Mergn Flutter Plugin'
  s.description      = <<-DESC
Mergn Flutter Plugin
                       DESC
  s.homepage         = 'https://mergn.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mergn' => 'dev@mergn.com' }
  s.source           = { :path => '.' }
  s.source_files = 'mergn_flutter_plugin/Sources/mergn_flutter_plugin/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
