Pod::Spec.new do |s|
  s.name     = 'LDProgressHUD'
  s.version  = '1.0.2'
  s.ios.deployment_target = '12.0'
  s.swift_version = '4.2'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A clean and lightweight progress HUD for your iOS and tvOS app.'
  s.homepage = 'https://github.com/dxluong/LDProgressHUD'
  s.authors   = { 'Luke Dinh' => 'luke@dinh.com' }
  s.source   = { :git => 'https://github.com/dxluong/LDProgressHUD.git', :tag => s.version.to_s }

  s.description = 'LDProgressHUD is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS and tvOS. The success and error icons are from Freepik from Flaticon and are licensed under Creative Commons BY 3.0.'

  s.framework    = 'QuartzCore'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'LDProgressHUD/*.{swift}'
    core.resources = ['LDProgressHUD/LDProgressHUD.bundle', 'LDProgressHUD/PrivacyInfo.xcprivacy']
  end
end
