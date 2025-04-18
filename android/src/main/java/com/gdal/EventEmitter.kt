package com.gdal

import android.system.Os
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import org.gdal.gdal.InfoOptions
import org.gdal.gdal.ProgressCallback
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


class EventEmitter(reactContext: ReactApplicationContext) :
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

  init {
    Companion.reactContext = reactContext
  }

  companion object {
    private var reactContext: ReactApplicationContext? = null
    const val NAME = "ProgressEventEmitter"
    fun sendProgress(params: WritableMap) {
      reactContext?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
        ?.emit("onProgress", params)
    }
  }
}
