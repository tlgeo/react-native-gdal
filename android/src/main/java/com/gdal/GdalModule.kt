package com.gdal

import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableArray
import org.gdal.gdal.InfoOptions
import org.gdal.gdal.TranslateOptions
import org.gdal.gdal.VectorInfoOptions
import org.gdal.gdal.VectorTranslateOptions
import org.gdal.gdal.gdal
import org.gdal.gdal.gdal.AllRegister
import org.gdal.gdal.gdal.GDALInfo
import org.gdal.gdal.gdal.GDALVectorInfo
import org.gdal.gdal.gdal.Open
import org.gdal.gdal.gdal.OpenEx
import org.gdal.gdalconst.gdalconst
import java.util.Vector


class GdalModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun getDrivers(promise: Promise) {
    try {
      // Register OGR drivers
      AllRegister();

      // Create a list to store driver names
      val drivers = ArrayList<String>()
      for (i in 0 until gdal.GetDriverCount()) {
        val driver = gdal.GetDriver(i)
        drivers.add(driver.shortName)
      }

      // Convert the list of driver names to a WritableArray
      val driversArray: WritableArray = Arguments.createArray()
      for (driver in drivers) {
        driversArray.pushString(driver)
      }

      // Resolve the promise with the WritableArray
      promise.resolve(driversArray)
    } catch (e: Exception) {
      // In case of error, reject the promise
      promise.reject("ERROR_GETTING_DRIVERS", e)
    }
  }



  @ReactMethod
  fun RNOgr2ogr(srcPath: String, destPath: String, args: ReadableArray, promise: Promise) {
    val strArgs = arrayOfNulls<String>(args.size())
    for (i in 0 until args.size()) {
      strArgs[i] = args.getString(i)
    }
    AllRegister()

    var src: String = srcPath
    var dest: String = destPath
    val newArgs = Vector<String>()

    // Mở dataset nguồn
    val srcDS = OpenEx(src)

    if (srcDS == null) {
      System.err.println("Không thể mở dataset nguồn.")
      promise.reject("ERROR_OPEN_SRC", "Không thể mở dataset nguồn.")
    }

    // Sử dụng Translate để chuyển đổi dataset sang tệp đích
    val outDS = gdal.VectorTranslate(dest, srcDS, VectorTranslateOptions(newArgs))

    if (outDS == null) {
      System.err.println("Dịch không thành công.")
      promise.reject("ERROR_TRANSLATE", "Dịch không thành công.")
    }

    println("Dịch thành công.")
    promise.resolve(destPath)
  }

  @ReactMethod
  fun RNOgrinfo(srcPath: String, args: ReadableArray, promise: Promise) {
    AllRegister()
    val vectorArgs = Vector<String>()
    val inputString = srcPath
    for (i in 0 until args.size()) {
      vectorArgs.add(args.getString(i))
    }
    val dataset = OpenEx(inputString)
    var vectorInfoOptions = VectorInfoOptions(vectorArgs)
    val ogrInfo = GDALVectorInfo(dataset, vectorInfoOptions)
    promise.resolve(ogrInfo)
  }

  @ReactMethod
  fun RNGdalinfo(srcPath: String, args: ReadableArray, promise: Promise) {
    AllRegister()
    val inputString = srcPath
    val vectorArgs = Vector<String>()
    for (i in 0 until args.size()) {
      vectorArgs.add(args.getString(i))
    }
    val dataset = OpenEx(inputString)
    var infoOptions = InfoOptions(vectorArgs)
    Log.d("TLGEO", "args: " + vectorArgs)
    val gdalInfo = GDALInfo(dataset, infoOptions)
    promise.resolve(gdalInfo)
  }

  @ReactMethod
  fun RNGdalTranslate(srcPath: String, destPath: String, args: ReadableArray, promise: Promise) {
    // Convert ReadableArray to String[]
    val strArgs = arrayOfNulls<String>(args.size())
    for (i in 0 until args.size()) {
      strArgs[i] = args.getString(i)
    }
    AllRegister()

    var src: String = srcPath
    var dest: String = destPath
    val newArgs = Vector<String>()

    // Mở dataset nguồn
    val srcDS = Open(src, gdalconst.GA_ReadOnly)

    if (srcDS == null) {
      System.err.println("Không thể mở dataset nguồn.")
        promise.reject("ERROR_OPEN_SRC", "Không thể mở dataset nguồn.")
    }

    // Sử dụng Translate để chuyển đổi dataset sang tệp đích
    val outDS = gdal.Translate(dest, srcDS, TranslateOptions(newArgs))

    if (outDS == null) {
      System.err.println("Dịch không thành công.")
      promise.reject("ERROR_TRANSLATE", "Dịch không thành công.")
    }

    println("Dịch thành công.")
    promise.resolve(destPath)
  }

  companion object {
    const val NAME = "Gdal"
  }
}
