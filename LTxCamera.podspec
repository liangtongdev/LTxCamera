Pod::Spec.new do |s|
  s.name         = "LTxCamera"
  s.version      = "0.0.2"
  s.summary      = "拍照，小视频，扫码，二维码生成"
  s.license      = "MIT"
  s.author             = { "liangtong" => "liangtongdev@163.com" }

  s.homepage     = "https://github.com/liangtongdev/LTxCamera"
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/liangtongdev/LTxCamera.git", :tag => "#{s.version}" }

  s.frameworks = "Foundation", "UIKit"
#  s.default_subspecs = "Shoot"

  # 核心模块
  s.subspec 'Common' do |common|
    common.source_files  =  "LTxCamera/Common/*.{h,m}"
    common.public_header_files = "LTxCamera/Common/*.h"
    common.resources = "LTxCamera/LTxCamera.bundle"
  end
  # 扫码
  s.subspec 'QRCode' do |qrcode|
    qrcode.source_files  =  "LTxCamera/CameraScan/*.{h,m}"
    qrcode.public_header_files = "LTxCamera/CameraScan/*.h"
    qrcode.dependency 'LTxCamera/Common'
  end
  # 拍摄
  s.subspec 'Shoot' do |shoot|
    shoot.source_files  =  "LTxCamera/CameraShoot/*.{h,m}"
    shoot.public_header_files = "LTxCamera/CameraShoot/*.h"
    shoot.dependency 'LTxCamera/Common'
  end
  
  # 公开
  s.subspec 'Core' do |core|
      core.source_files  =  "LTxCamera/LTxCamera.h"
      core.public_header_files = "LTxCamera/LTxCamera.h"
      core.dependency 'LTxCamera/QRCode'
      core.dependency 'LTxCamera/Shoot'
  end

end
