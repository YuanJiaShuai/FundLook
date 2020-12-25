source 'https://github.com/CocoaPods/Specs.git'
source 'https://gitee.com/yuan_js/YJSSpec.git'

project 'FundLook.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :macos, '10.10'
# 忽略引入库的所有警告
inhibit_all_warnings!

def common_pods
  pod 'AFNetworking'
  pod 'Masonry'
  pod 'FMDB'
end

target 'FundLook' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!
  ##############基础三方库###############
  common_pods
  pod 'SSZipArchive'
end

target 'FundLookWidget' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!
  ##############基础三方库###############
  common_pods
  pod 'SSZipArchive'
end
