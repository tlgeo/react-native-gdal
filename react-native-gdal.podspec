require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name         = "react-native-gdal"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://www.npmjs.com/package/react-native-gdal.git", :tag => "#{s.version}" }

  s.source_files = ["ios/*.{a,h,m,mm,swift}",
    'ios/libgdal.xcframework/ios-arm64_x86_64-simulator/Headers/gdal.h',
    'ios/libgdal.xcframework/ios-arm64_x86_64-simulator/Headers/ogr_api.h',
    'ios/libgdal.xcframework/ios-arm64_x86_64-simulator/Headers/ogr_srs_api.h',
    'ios/libgdal.xcframework/ios-arm64_x86_64-simulator/Headers/proj.h',
    'ios/libgdal.xcframework/ios-arm64_x86_64-simulator/Headers/gdal_utils.h'
  ]

  s.vendored_frameworks = ['ios/libgdal.xcframework']
  # header "gdal.h"
  #   header "ogr_api.h"
  #   header "ogr_srs_api.h"
  #   header "proj.h"
  #   header "gdal_utils.h"
  #   header "expat.h"

  # Exclude conflicting headers
  s.exclude_files = 'ios/libgdal.xcframework/ios-arm64_x86_64-simulator/Headers/*',"ios/libgdal.xcframework/**/cpl_minizip_*","ios/libgdal.xcframework/**/gdalpansharpen*","ios/libgdal.xcframework/**/cpl_spawn*"

  s.dependency 'React'
  s.dependency "React-CoreModules"
  s.dependency "React-Core"
  s.dependency "RCT-Folly"
  # s.dependency "React-jsinspector"
  # s.dependency "React-cxxreact"

  install_modules_dependencies(s)

  s.pod_target_xcconfig    = {
      # "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/c++/v1",
      "HEADER_SEARCH_PATHS" => ["$(inherited)", "$(PODS_ROOT)/../../node_modules/react-native/ReactCommon"],
      "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -stdlib=libc++",
      "CLANG_CXX_LANGUAGE_STANDARD" => "c++17",
      "CLANG_CXX_LIBRARY" => "libc++",
      "SWIFT_OBJC_INTEROP_MODE" => "objcxx",
      "OTHER_LDFLAGS" => ['$(inherited)', '-ObjC', '-lc++', '-liconv', '-lsqlite3', '-lxml2', '-lz', '-lexpat']
  }
  s.compiler_flags = folly_compiler_flags

  # Use install_modules_dependencies helper to install the dependencies if React Native version >=0.71.0.
  # See https://github.com/facebook/react-native/blob/febf6b7f33fdb4904669f99d795eba4c0f95d7bf/scripts/cocoapods/new_architecture.rb#L79.
  # if respond_to?(:install_modules_dependencies, true)
  #   install_modules_dependencies(s)
  # else
  #   s.dependency 'React'
  #   s.dependency "React-CoreModules"
  #   s.dependency "React-Core"
  #   s.dependency "RCT-Folly"
    # s.dependency "React-Core"
    # Don't install the dependencies when we run `pod install` in the old architecture.
    # if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
    #   s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
    #   s.pod_target_xcconfig    = {
    #       "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
    #       "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -stdlib=libc++",
    #       "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
    #   }
    #   s.dependency "React-Codegen"
    #   s.dependency "RCT-Folly"
    #   s.dependency "RCTRequired"
    #   s.dependency "RCTTypeSafety"
    #   s.dependency "ReactCommon/turbomodule/core"
    # end
  # end
end
