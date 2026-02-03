Pod::Spec.new do |s|
  s.name         = 'EpicUnityBridge'
  s.version      = '0.1.0'
  s.summary      = 'Unity scene integration bridge for Epic app'
  s.description  = 'Provides plugin registration, scene management, and business plugins for Unity integration, replacing SCUnityBusiness.'
  s.homepage     = 'https://getepic.com'
  s.license      = { :type => 'Proprietary' }
  s.author       = 'Epic'
  s.platform     = :ios, '12.2'
  s.source       = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'
  s.frameworks   = 'UIKit', 'Foundation', 'AudioToolbox'
  s.dependency 'NTUnityIn'
  s.dependency 'EpicUnityAdapter'
  s.dependency 'TALMsgSdk'
  s.dependency 'TALPush'
end
