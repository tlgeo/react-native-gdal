#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Gdal, NSObject)

RCT_EXTERN_METHOD(getDrivers:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(RNOgr2ogr:(NSArray<NSString *> *)args
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
