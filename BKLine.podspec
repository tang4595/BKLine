$version = "0.0.1"

Pod::Spec.new do |s|
  s.name         = "BKLine" 
  s.version      = $version
  s.summary      = "BKLine."
  s.description  = "BKLine."
  s.homepage     = "https://www.bkex.com"
  
  s.license      = "MIT"
  s.author       = { "bkex" => "bkex@bkex.com" }
  s.source       = { :git => "http://gitlab.bkex.io/mobile/mobile-bkex-ios.git", :tag => $version }
  s.source_files = "Library/BKLine/**/*.swift"
  s.resource     = ['Library/BKLine/KLineChart/TradingView/*']

  s.dependency 'SnapKit'
  s.dependency 'SwifterSwift'
  s.dependency 'WebViewJavascriptBridge'

  s.platform = :ios, "11.0"
  s.swift_versions = ['5.0', '5.1', '5.2']
  s.pod_target_xcconfig = { 'c' => '-Owholemodule' }
end

