Pod::Spec.new do |s|
  s.name         = "LTxCamera"
  s.version      = "0.0.1"
  s.summary      = "Custom camera viewController , including photo-shooting and video-recording "
  s.license      = "MIT"
  s.author             = { "liangtong" => "l900416@163.com" }

  s.homepage     = "https://github.com/liangtongdev/LTxCamera"
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/liangtongdev/LTxCamera.git", :tag => "#{s.version}" }

  s.frameworks = "Foundation", "UIKit"

  s.source_files  =  "LTxCamera/*.{h,m}"
  s.public_header_files = "LTxCamera/*.h"
  s.resources = "LTxCamera/LTxCamera.bundle"


end
