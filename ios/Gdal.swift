import Foundation

@objc(Gdal)
class Gdal: NSObject {

    @objc(RNStartAccessingSecurityScopedResource:withResolver:withRejecter:)
    func RNStartAccessingSecurityScopedResource(filePath: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        let fileUrl = URL(fileURLWithPath: filePath)

        let result = fileUrl.startAccessingSecurityScopedResource()
        if result {
            print("Successfully accessed security scoped resource.")
            resolve("Successfully accessed security scoped resource.")
        } else {
            print("Failed to access security scoped resource.")
            reject("1", "Failed to access security scoped resource.", nil)
        }
    }
    @objc(getDrivers:withRejecter:)
    func getDrivers(
        resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock
    ) {
        GDALAllRegister()

        let driverCount = GDALGetDriverCount()

        print("Available GDAL Drivers:")
        var drivers: [String] = []

        for i in 0..<driverCount {
            if let driver = GDALGetDriver(i) {
                if let driverName = GDALGetDriverShortName(driver) {
                    let name = String(cString: driverName)
                    drivers.append(name)
                }
            }
        }

        resolve(drivers)
    }
    
    @objc(RNOgr2ogr:withDestPath:withArgs:withResolver:withRejecter:)
    func RNOgr2ogr(srcPath: String, destPath: String, args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        let input = srcPath
        let output = destPath
        GDALAllRegister()

        let inputUrl = URL(fileURLWithPath: "file://\(input)")
        let outputUrl = URL(fileURLWithPath: "file://\(output)")

        inputUrl.startAccessingSecurityScopedResource()
        outputUrl.startAccessingSecurityScopedResource()

        print("args \(args)")

        // Mở dataset đầu vào
        guard let inputDataset = GDALOpenEx(
            input.cString(using: .utf8), UInt32(GDAL_OF_VECTOR), nil, nil, nil)
        else {
            print("Failed to open input dataset.")
            reject("1", "Failed to open input dataset.", nil)
            return
        }

        let layerCount = GDALDatasetGetLayerCount(inputDataset)
        guard layerCount > 0 else {
            print("No layers found in the dataset.")
            GDALClose(inputDataset)
            reject("1", "No layers found in the dataset.", nil)
            return
        }

        var optionsArray = args

        // Lặp qua tất cả các lớp và thêm chúng vào danh sách options
        for i in 0..<layerCount {
            if let layer = GDALDatasetGetLayer(inputDataset, i) {
                let layerName = String(cString: OGR_L_GetName(layer))
                optionsArray.append(layerName)
            }
        }

        print("Layer Names: \(optionsArray)")

        let progressCallback: @convention(c) (Double, UnsafePointer<Int8>?, UnsafeMutableRawPointer?) -> Int32 = { progress, message, userData in
            if let message = message {
                print("Progress: \(Int(progress * 100))%, Message: \(String(cString: message))")
            } else {
                print("Progress: \(Int(progress * 100))%")
            }
            DispatchQueue.main.async {
                   Ogr2ogrEventEmitter.eventEmitter?.sendEvent(
                       withName: "onProgress",
                       body: ["progress": progress]
                   )
               }
            return 1 // Return 1 to continue processing, 0 to cancel
        }

        var options = cStringArray(from: optionsArray)
        let translateOptions = GDALVectorTranslateOptionsNew(options, nil)

        var srcDS: [GDALDatasetH?] = [inputDataset]
        srcDS.withUnsafeMutableBufferPointer { srcDSPointer in
            GDALVectorTranslateOptionsSetProgress(translateOptions, progressCallback, nil)
            
            let geojsonDataset = GDALVectorTranslate(
                output.cString(using: .utf8),  // Output file
                nil,  // Destination dataset (NULL for creating a new one)
                1,  // Number of input datasets
                UnsafeMutablePointer(srcDSPointer.baseAddress!),  // Input datasets array
                translateOptions,  // translateOptions,                        // Translation options
                nil  // Progress callback
            )

            GDALVectorTranslateOptionsFree(translateOptions)
            GDALClose(inputDataset)
            if geojsonDataset != nil {
                GDALClose(geojsonDataset)
                print("Successfully converted to GeoJSON")
                resolve(output)
            } else {
                print("Failed to convert to GeoJSON.")
                reject("1", "Failed to convert to GeoJSON.", nil)
            }
        }
    }

    @objc(RNOgrinfo:withArgs:withResolver:withRejecter:)
    func RNOgrinfo(srcPath: String, args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        let input = srcPath
        GDALAllRegister()
        
        let inputUrl = URL(fileURLWithPath: "file://\(input)")

        let result = inputUrl.startAccessingSecurityScopedResource()
        print("startAccessingSecurityScopedResource result \(result)")

        // Open input dataset
        guard
            let inputDataset = GDALOpenEx(
                input.cString(using: .utf8), UInt32(GDAL_OF_VECTOR), nil, nil, nil)
        else {
            print("Failed to open input dataset.")
            reject("1", "Failed to open input dataset.", nil)
            return
        }

        // Get the first layer name (you can modify this to use a specific layer index if needed)
        let layerCount = GDALDatasetGetLayerCount(inputDataset)
        guard layerCount > 0 else {
            print("No layers found in the dataset.")
            GDALClose(inputDataset)
            reject("1", "No layers found in the dataset.", nil)
            return
        }

        // Fetch the first layer
        guard let layer = GDALDatasetGetLayer(inputDataset, 0) else {
            print("Failed to get the layer.")
            GDALClose(inputDataset)
            reject("1", "Failed to get the layer.", nil)
            return
        }

        // Get layer name
        let layerName = String(cString: OGR_L_GetName(layer))
        print("Layer Name: \(layerName)")

        // Prepare options for GDALInfo
        var optionsArray = args
        optionsArray.append(layerName)
        var options = cStringArray(from: optionsArray)
        let infoOptions = GDALVectorInfoOptionsNew(options, nil)

        // Get information about the dataset
        if let info = GDALVectorInfo(inputDataset, infoOptions) {
            let infoString = String(cString: info)
            print("Dataset Info: \(infoString)")
            GDALVectorInfoOptionsFree(infoOptions)
            resolve(infoString)
            GDALClose(inputDataset)
            return
        } else {
            print("Failed to get dataset info.")
            GDALVectorInfoOptionsFree(infoOptions)
            reject("1", "Failed to get dataset info.", nil)
            GDALClose(inputDataset)
            return
        }
    }

    @objc(RNGdalinfo:withArgs:withResolver:withRejecter:)
    func RNGdalinfo(srcPath: String, args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        let input = srcPath
        GDALAllRegister()
        
        let inputUrl = URL(fileURLWithPath: "file://\(input)")

        let result = inputUrl.startAccessingSecurityScopedResource()
        print("startAccessingSecurityScopedResource result \(result)")

        // Open input dataset
        guard
            let inputDataset = GDALOpenEx(
                input.cString(using: .utf8), UInt32(GDAL_OF_RASTER), nil, nil, nil)
        else {
            print("Failed to open input dataset.")
            reject("1", "Failed to open input dataset.", nil)
            return
        }


        // Prepare options for GDALInfo
        var optionsArray = args
        var options = cStringArray(from: optionsArray)
        let infoOptions = GDALInfoOptionsNew(options, nil)

        // Get information about the dataset
        if let info = GDALInfo(inputDataset, infoOptions) {
            let infoString = String(cString: info)
            print("Dataset Info: \(infoString)")
            GDALInfoOptionsFree(infoOptions)
            resolve(infoString)
            GDALClose(inputDataset)
        } else {
            print("Failed to get dataset info.")
            GDALInfoOptionsFree(infoOptions)
            reject("1", "Failed to get dataset info.", nil)
            GDALClose(inputDataset)
        }
    }

    @objc(RNGdalTranslate:withDestPath:withArgs:withResolver:withRejecter:)
    func RNGdalTranslate(srcPath: String, destPath: String, args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        let input = srcPath
        let output = destPath
        
        print("input \(input)")
        print("output \(output)")
        
        GDALAllRegister()
        
        let inputUrl = URL(fileURLWithPath: "file://\(input)")
        let outputUrl = URL(fileURLWithPath: "file://\(output)")

        inputUrl.startAccessingSecurityScopedResource()
        outputUrl.startAccessingSecurityScopedResource()

        // Open input dataset
        guard
            let inputDataset = GDALOpen(
                input.cString(using: .utf8), GA_ReadOnly)
        else {
            print("Failed to open input dataset.")
            return
        }

        var optionsArray = args
        var options = cStringArray(from: optionsArray)
        // Translate options for GDALVectorTranslate
        let translateOptions = GDALTranslateOptionsNew(options, nil)

        let progressCallback: GDALProgressFunc = { (complete, message, userData) -> Int32 in
            let percent = Int(complete * 100)
            
            if let emitter = Ogr2ogrEventEmitter.eventEmitter {
                emitter.sendEvent(withName: "onProgress", body: [
                    "progress": percent
                ])
            }

            return 1
        }
        
        GDALTranslateOptionsSetProgress(translateOptions, progressCallback, nil)

        //        var srcDS: [OpaquePointer?] = [OpaquePointer(inputDataset)]
        var srcDS: GDALDatasetH? = inputDataset
        // Translate input dataset to GeoJSON
        let geojsonDataset = GDALTranslate(
            output.cString(using: .utf8),  // Output file
            srcDS,  // Source dataset
            translateOptions,  // translateOptions,                        // Translation options
            nil  // Progress callback
        )

        // Cleanup
        GDALTranslateOptionsFree(translateOptions)
        GDALClose(inputDataset)
        if geojsonDataset != nil {
            GDALClose(geojsonDataset)
        }

        if geojsonDataset == nil {
            print("Failed to convert to GeoJSON.")
        } else {
            print("Successfully converted to GeoJSON")
        }
        resolve(destPath)
    }

    @objc(RNGdalAddo:withOverviews:withResolver:withRejecter:)
    func RNGdalAddo(srcPath: String, overviews: [Int], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        let input = srcPath
        GDALAllRegister()
        
        let inputUrl = URL(fileURLWithPath: "file://\(input)")

        inputUrl.startAccessingSecurityScopedResource()

        // Open input dataset
        guard
            let inputDataset = GDALOpen(
                input.cString(using: .utf8), GA_Update)
        else {
            print("Failed to open input dataset.")
            reject("1", "Failed to open input dataset.", nil)
            return
        }
        
        print("Opened dataset: \(inputDataset)")

        // Convert [Int] to [Int32]
        print("overviews \(overviews)")
        let int32Overviews = overviews.map { Int32($0) }
        
        print("int32Overviews \(int32Overviews)")
        
        let progressCallback: GDALProgressFunc = { (complete, message, userData) -> Int32 in
            let percent = Int(complete * 100)
            
            if let emitter = Ogr2ogrEventEmitter.eventEmitter {
                emitter.sendEvent(withName: "onProgress", body: [
                    "progress": percent
                ])
            }

            return 1
        }

        // Add overviews
        let result = GDALBuildOverviews(
            inputDataset,
            "AVERAGE",
            Int32(int32Overviews.count),
            int32Overviews,
            0,
            nil,
            progressCallback,
            nil
        )


        if result == CE_None {
            print("Successfully added overviews.")
            resolve("Successfully added overviews.")
        } else {
            print("Failed to add overviews.")
            reject("1", "Failed to add overviews.", nil)
        }

        GDALClose(inputDataset)
    }


    

    // Function to convert an array of Swift strings to a C-style array of C strings
    func cStringArray(from options: [String]) -> UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
    {
        let count = options.count
        let array = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: count + 1)

        for (index, option) in options.enumerated() {
            // Use strdup to allocate a C string for each option
            array[index] = strdup(option)!
        }

        array[count] = nil  // Null-terminate the array
        return array
    }
}
