Pod::Spec.new do |s|
    s.name         = "LTxCamera"
    s.version      = "0.0.5"
    s.summary      = "拍照，小视频，扫码，二维码生成"
    s.license      = "MIT"
    s.author             = { "liangtong" => "liangtongdev@163.com" }
    
    s.homepage     = "https://github.com/liangtongdev/LTxCamera"
    s.platform     = :ios, "9.0"
    s.ios.deployment_target = "9.0"
    s.source       = { :git => "https://github.com/liangtongdev/LTxCamera.git", :tag => "#{s.version}" }
    
    s.frameworks = "Foundation", "UIKit"
    #  s.default_subspecs = "Shoot"
    
    # Model
    s.subspec 'Model' do |model|
        model.source_files  =  "LTxCamera/Model/*.{h,m}"
        model.public_header_files = "LTxCamera/Model/*.h"
    end
    
    # 核心模块
    s.subspec 'Common' do |common|
        common.source_files  =  "LTxCamera/Common/*.{h,m}"
        common.public_header_files = "LTxCamera/Common/*.h"
        common.resources = "LTxCamera/LTxCamera.bundle"
        common.dependency 'LTxCamera/Model'
    end
    
    # View
    s.subspec 'View' do |view|
        view.source_files  =  "LTxCamera/View/*.{h,m}"
        view.public_header_files = "LTxCamera/View/*.h"
        view.dependency 'LTxCamera/Common'
    end
    
    # 扫码
    s.subspec 'Scan' do |scan|
        scan.source_files  =  "LTxCamera/Scan/*.{h,m}"
        scan.public_header_files = "LTxCamera/Scan/*.h"
        scan.dependency 'LTxCamera/Common'
    end
    # 拍摄
    s.subspec 'Shoot' do |shoot|
        shoot.source_files  =  "LTxCamera/Shoot/*.{h,m}"
        shoot.public_header_files = "LTxCamera/Shoot/*.h"
        shoot.dependency 'LTxCamera/Common'
    end
    # 相册
    s.subspec 'Ablum' do |ablum|
        ablum.source_files  =  "LTxCamera/Ablum/*.{h,m}"
        ablum.public_header_files = "LTxCamera/Ablum/*.h"
        ablum.dependency 'LTxCamera/Common'
    end
    
    # 公开
    s.subspec 'Core' do |core|
        core.source_files  =  "LTxCamera/LTxCamera.h"
        core.public_header_files = "LTxCamera/LTxCamera.h"
        core.dependency 'LTxCamera/Scan'
        core.dependency 'LTxCamera/Shoot'
        core.dependency 'LTxCamera/Ablum'
    end
    
end
