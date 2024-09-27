package com.gdal

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray


class GdalModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun multiply(a: Double, b: Double, promise: Promise) {
    promise.resolve(a * b)
  }

  @ReactMethod
  fun RNOgr2ogr(args: ReadableArray, promise: Promise) {
    // Convert ReadableArray to String[]
    val strArgs = arrayOfNulls<String>(args.size())
    for (i in 0 until args.size()) {
      strArgs[i] = args.getString(i)
    }
    // Pass the string array to ogr2ogr
    ogr2ogr.main(strArgs)
    promise.resolve("Success")
  }

  @ReactMethod
  fun RNOgrinfo(args: ReadableArray, promise: Promise) {
    // Convert ReadableArray to String[]
    val strArgs = arrayOfNulls<String>(args.size())
    for (i in 0 until args.size()) {
      strArgs[i] = args.getString(i)
    }
    // Pass the string array to ogrinfo
    ogrinfo.main(strArgs)
    promise.resolve("Success")
  }

  @ReactMethod
  fun RNGdalinfo(args: ReadableArray, promise: Promise) {
    // Convert ReadableArray to String[]
    val strArgs = arrayOfNulls<String>(args.size())
    for (i in 0 until args.size()) {
      strArgs[i] = args.getString(i)
    }
    // Pass the string array to gdalinfo
    gdalinfo.main(strArgs)
    promise.resolve("Success")
  }

  @ReactMethod
  fun RNGdalTranslate(args: ReadableArray, promise: Promise) {
    // Convert ReadableArray to String[]
    val strArgs = arrayOfNulls<String>(args.size())
    for (i in 0 until args.size()) {
      strArgs[i] = args.getString(i)
    }
    // Pass the string array to ogr2ogr
    gdal_translate.main(strArgs)
    promise.resolve("Success")
  }

  companion object {
    const val NAME = "Gdal"
  }
}
