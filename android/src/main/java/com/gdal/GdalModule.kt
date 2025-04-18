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
import com.facebook.react.bridge.WritableNativeMap
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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch // Add this import
import kotlinx.coroutines.withContext // Add this import

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
    // Convert ReadableArray to Vector<String>
    val newArgs = Vector<String>()
    for (i in 0 until args.size()) {
      newArgs.add(args.getString(i))
    }

    // Initialize GDAL
    AllRegister()

    // Run the heavy operation in a background thread using coroutines
    CoroutineScope(Dispatchers.IO).launch {
      try {
        // Open source dataset
        val srcDS = OpenEx(srcPath)
        if (srcDS == null) {
          withContext(Dispatchers.Main) {
            promise.reject("ERROR_OPEN_SRC", "Không thể mở dataset nguồn.")
          }
          return@launch
        }

        // Define progress callback
        val progressCallback = object : ProgressCallback() {
          override fun run(dfComplete: Double, message: String?): Int {
            // Create params for the event
            val params: WritableMap = WritableNativeMap().apply {
              putDouble("progress", dfComplete)
              putString("message", message)
            }

            // Send progress event on the main thread
            CoroutineScope(Dispatchers.Main).launch {
              EventEmitter.sendProgress(params)
            }
            return 1 // Continue
          }
        }

        // Perform VectorTranslate
        val outDS = gdal.VectorTranslate(
          destPath,
          srcDS,
          VectorTranslateOptions(newArgs),
          progressCallback
        )

        if (outDS == null) {
          withContext(Dispatchers.Main) {
            promise.reject("ERROR_TRANSLATE", "Dịch không thành công.")
          }
          return@launch
        }

        // Flush cache and commit
        outDS.FlushCache()
        outDS.delete()

        // Resolve promise on the main thread
        withContext(Dispatchers.Main) {
          promise.resolve(destPath)
        }
      } catch (e: Exception) {
        // Handle any unexpected errors
        withContext(Dispatchers.Main) {
          promise.reject("ERROR_UNEXPECTED", e.message ?: "Lỗi không xác định.")
        }
      }
    }
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
    val gdalInfo = GDALInfo(dataset, infoOptions)
    promise.resolve(gdalInfo)
  }

  @ReactMethod
  fun RNGdalTranslate(srcPath: String, destPath: String, args: ReadableArray, promise: Promise) {
    // Convert ReadableArray to Vector<String>
    val newArgs = Vector<String>()
    for (i in 0 until args.size()) {
      newArgs.add(args.getString(i))
    }

    // Đăng ký GDAL
    AllRegister()

    CoroutineScope(Dispatchers.IO).launch {
      try {
        // Mở dataset nguồn
        val srcDS = Open(srcPath, gdalconst.GA_ReadOnly)
        if (srcDS == null) {
          withContext(Dispatchers.Main) {
            promise.reject("ERROR_OPEN_SRC", "Không thể mở dataset nguồn.")
          }
          return@launch
        }

        // Khởi tạo callback tiến trình
        val progressCallback = object : ProgressCallback() {
          override fun run(dfComplete: Double, message: String?): Int {
            val params: WritableMap = WritableNativeMap().apply {
              putDouble("progress", dfComplete)
              putString("message", message)
            }

            CoroutineScope(Dispatchers.Main).launch {
              EventEmitter.sendProgress(params)
            }

            return 1 // tiếp tục
          }
        }

        // Thực hiện chuyển đổi
        val outDS = gdal.Translate(destPath, srcDS, TranslateOptions(newArgs), progressCallback)

        if (outDS == null) {
          withContext(Dispatchers.Main) {
            promise.reject("ERROR_TRANSLATE", "Dịch không thành công.")
          }
          return@launch
        }

        // Thành công
        withContext(Dispatchers.Main) {
          promise.resolve(destPath)
        }
      } catch (e: Exception) {
        withContext(Dispatchers.Main) {
          promise.reject("EXCEPTION", e.message)
        }
      }
    }
  }


  @ReactMethod
  fun RNSetProjLibPath(projLibPath: String, promise: Promise) {
    try {
      Os.setenv("PROJ_LIB", projLibPath, true)
      promise.resolve("Success")
    } catch (e: Exception) {
      promise.reject("ERROR_SET_PROJ_LIB", e)
    }
  }

  @ReactMethod
  fun RNGdalAddo(srcPath: String, overviews: ReadableArray, promise: Promise) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        AllRegister()

        val dataset = OpenEx(srcPath, gdalconst.GA_Update.toLong())

        if (dataset == null) {
          Log.d("TLGEO", "RNGdalAddo: " + gdal.GetLastErrorMsg())
          withContext(Dispatchers.Main) {
            promise.reject("ERROR_OPEN_SRC", "Không thể mở dataset nguồn.")
          }
          return@launch
        }

        // Chuyển ReadableArray thành IntArray
        val levels = overviews.toArrayList().map {
          (it as Double).toInt()
        }.toIntArray()

        // Tạo ProgressCallback
        val progressCallback = object : ProgressCallback() {
          override fun run(dfComplete: Double, message: String?): Int {
            val params: WritableMap = WritableNativeMap().apply {
              putDouble("progress", dfComplete)
              putString("message", message)
            }

            Log.d("RNGdalAddo", "run: $dfComplete")

            CoroutineScope(Dispatchers.Main).launch {
              EventEmitter.sendProgress(params)
            }

            return 1 // tiếp tục
          }
        }

        // Thêm overview với tiến trình
        dataset.BuildOverviews("NEAREST", levels, progressCallback)

        withContext(Dispatchers.Main) {
          promise.resolve("Success")
        }
      } catch (e: Exception) {
        withContext(Dispatchers.Main) {
          promise.reject("ERROR_ADDING_OVERVIEWS", e.message, e)
        }
      }
    }
  }


  companion object {
    const val NAME = "Gdal"
  }
}
