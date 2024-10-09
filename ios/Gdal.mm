#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Gdal, NSObject)

RCT_EXTERN_METHOD(getDrivers:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(RNOgr2ogr:(NSString *)srcPath
                 withDestPath:(NSString *)destPath
                 withArgs:(NSArray<NSString *> *)args
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(RNOgrinfo:(NSString *)srcPath
                 withArgs:(NSArray<NSString *> *)args
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(RNGdalTranslate:(NSString *)srcPath
                 withDestPath:(NSString *)destPath
                 withArgs:(NSArray<NSString *> *)args
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(RNGdalinfo:(NSString *)srcPath
                 withArgs:(NSArray<NSString *> *)args
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(RNGdalAddo:(NSString *)srcPath
                 withOverviews:(NSArray<NSNumber *> *)overviews
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
