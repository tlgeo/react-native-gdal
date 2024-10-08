package com.gdal

import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableArray
import org.gdal.gdal.Dataset
import org.gdal.gdal.InfoOptions
import org.gdal.gdal.VectorInfoOptions
import org.gdal.gdal.gdal
import org.gdal.gdal.gdal.AllRegister
import org.gdal.gdal.gdal.GDALInfo
import org.gdal.ogr.ogr
import org.gdal.gdal.gdal.GDALVectorInfo
import org.gdal.gdal.gdal.Open
import org.gdal.gdal.gdal.GetLastErrorMsg
import org.gdal.gdal.gdal.OpenEx
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
    AllRegister()
    val strArgs = arrayOfNulls<String>(args.size())
    for (i in 0 until args.size()) {
      strArgs[i] = args.getString(i)
    }
    val inputString = args.getString(0)
    val args = Vector<String>()
    for (i in strArgs.indices) {
      if (i != 0) {
        args.add(strArgs[i])
      }
    }
    val dataset = OpenEx(inputString)
    var vectorInfoOptions = VectorInfoOptions(args)
    val ogrInfo = GDALVectorInfo(dataset, vectorInfoOptions)
    promise.resolve(ogrInfo)
  }

  @ReactMethod
  fun RNGdalinfo(args: ReadableArray, promise: Promise) {
    AllRegister()
    val strArgs = arrayOfNulls<String>(args.size())
    for (i in 0 until args.size()) {
      strArgs[i] = args.getString(i)
    }
    val inputString = args.getString(0)
    val args = Vector<String>()
    for (i in strArgs.indices) {
      if (i != 0) {
        args.add(strArgs[i])
      }
    }
    val dataset = OpenEx(inputString)
    var infoOptions = InfoOptions(args)
    val gdalInfo = GDALInfo(dataset, infoOptions)
    promise.resolve(gdalInfo)
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
