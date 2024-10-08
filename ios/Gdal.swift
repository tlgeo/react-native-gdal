@objc(Gdal)
class Gdal: NSObject {

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

    @objc(RNOgr2ogr:withResolver:withRejecter:)
    func RNOgr2ogr(args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        ogr2ogr_translate(args: args)
        resolve(args[2])
    }

    @objc(RNOgrinfo:withResolver:withRejecter:)
    func RNOgrinfo(args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        resolve(ogrinfo(args: args))
    }

    @objc(RNGdalinfo:withResolver:withRejecter:)
    func RNGdalinfo(args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        resolve(gdalinfo(args: args))
    }

    @objc(RNGdalTranslate:withResolver:withRejecter:)
    func RNGdalTranslate(args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        gdal_translate(args: args)
        resolve(args[2])
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

    func gdal_translate(args: [String]) {
        let input = args[3]
        let output = args[2]
        
        print("input \(input)")
        print("output \(output)")
        
        GDALAllRegister()

        // Open input dataset
        guard
            let inputDataset = GDALOpen(
                input.cString(using: .utf8), GA_ReadOnly)
        else {
            print("Failed to open input dataset.")
            return
        }

        var optionsArray = args.enumerated().filter { index, _ in index != 2 && index != 3 }.map { $0.element }
        var options = cStringArray(from: optionsArray)
        // Translate options for GDALVectorTranslate
        let translateOptions = GDALTranslateOptionsNew(options, nil)

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

    }

    func ogr2ogr_translate(args: [String]) {
        let input = args[3]
        let output = args[2]
        GDALAllRegister()

        // Open input dataset
        guard
            let inputDataset = GDALOpenEx(
                input.cString(using: .utf8), UInt32(GDAL_OF_VECTOR), nil, nil, nil)
        else {
            print("Failed to open input dataset.")
            return
        }

        // Get the first layer name (you can modify this to use a specific layer index if needed)
        let layerCount = GDALDatasetGetLayerCount(inputDataset)
        guard layerCount > 0 else {
            print("No layers found in the dataset.")
            GDALClose(inputDataset)
            return
        }

        // Fetch the first layer
        guard let layer = GDALDatasetGetLayer(inputDataset, 0) else {
            print("Failed to get the layer.")
            GDALClose(inputDataset)
            return
        }

        let layerName = String(cString: OGR_L_GetName(layer))
        print("Layer Name: \(layerName)")

        var optionsArray = args.enumerated().filter { index, _ in index != 2 && index != 3 }.map { $0.element }
        optionsArray.append(layerName)
        var options = cStringArray(from: optionsArray)
        // Translate options for GDALVectorTranslate
        let translateOptions = GDALVectorTranslateOptionsNew(options, nil)

        //        var srcDS: [OpaquePointer?] = [OpaquePointer(inputDataset)]
        var srcDS: [GDALDatasetH?] = [inputDataset]
        srcDS.withUnsafeMutableBufferPointer { srcDSPointer in
            // Translate input dataset to GeoJSON
            let geojsonDataset = GDALVectorTranslate(
                output.cString(using: .utf8),  // Output file
                nil,  // Destination dataset (NULL for creating a new one)
                1,  // Number of input datasets
                UnsafeMutablePointer(srcDSPointer.baseAddress!),  // Input datasets array
                translateOptions,  // translateOptions,                        // Translation options
                nil  // Progress callback
            )

            // Cleanup
            GDALVectorTranslateOptionsFree(translateOptions)
            GDALClose(inputDataset)
            if geojsonDataset != nil {
                GDALClose(geojsonDataset)
            }

            if geojsonDataset == nil {
                print("Failed to convert to GeoJSON.")
            } else {
                print("Successfully converted to GeoJSON")
            }
        }

    }

    func ogrinfo(args: [String]) -> String? {
        let input = args[0]
        GDALAllRegister()

        // Open input dataset
        guard
            let inputDataset = GDALOpenEx(
                input.cString(using: .utf8), UInt32(GDAL_OF_VECTOR), nil, nil, nil)
        else {
            print("Failed to open input dataset.")
            return nil
        }

        // Get the first layer name (you can modify this to use a specific layer index if needed)
        let layerCount = GDALDatasetGetLayerCount(inputDataset)
        guard layerCount > 0 else {
            print("No layers found in the dataset.")
            GDALClose(inputDataset)
            return nil
        }

        // Fetch the first layer
        guard let layer = GDALDatasetGetLayer(inputDataset, 0) else {
            print("Failed to get the layer.")
            GDALClose(inputDataset)
            return nil
        }

        // Get layer name
        let layerName = String(cString: OGR_L_GetName(layer))
        print("Layer Name: \(layerName)")

        // Prepare options for GDALInfo
        var optionsArray = args.enumerated().filter { index, _ in index != 0 }.map { $0.element }
        optionsArray.append(layerName)
        var options = cStringArray(from: optionsArray)
        let infoOptions = GDALVectorInfoOptionsNew(options, nil)

        // Get information about the dataset
        if let info = GDALVectorInfo(inputDataset, infoOptions) {
            let infoString = String(cString: info)
            print("Dataset Info: \(infoString)")
            GDALVectorInfoOptionsFree(infoOptions)
            return infoString
            GDALClose(inputDataset)
        } else {
            print("Failed to get dataset info.")
            GDALVectorInfoOptionsFree(infoOptions)
            return nil
            GDALClose(inputDataset)
        }
    }

    func gdalinfo(args: [String]) -> String? {
        let input = args[0]
        GDALAllRegister()

        // Open input dataset
        guard
            let inputDataset = GDALOpenEx(
                input.cString(using: .utf8), UInt32(GDAL_OF_VECTOR), nil, nil, nil)
        else {
            print("Failed to open input dataset.")
            return nil
        }

        // Get the first layer name (you can modify this to use a specific layer index if needed)
        let layerCount = GDALDatasetGetLayerCount(inputDataset)
        guard layerCount > 0 else {
            print("No layers found in the dataset.")
            GDALClose(inputDataset)
            return nil
        }

        // Fetch the first layer
        guard let layer = GDALDatasetGetLayer(inputDataset, 0) else {
            print("Failed to get the layer.")
            GDALClose(inputDataset)
            return nil
        }

        // Get layer name
        let layerName = String(cString: OGR_L_GetName(layer))
        print("Layer Name: \(layerName)")

        // Prepare options for GDALInfo
        var optionsArray = args.enumerated().filter { index, _ in index != 0 }.map { $0.element }
        optionsArray.append(layerName)
        var options = cStringArray(from: optionsArray)
        let infoOptions = GDALInfoOptionsNew(options, nil)

        // Get information about the dataset
        if let info = GDALInfo(inputDataset, infoOptions) {
            let infoString = String(cString: info)
            print("Dataset Info: \(infoString)")
            GDALInfoOptionsFree(infoOptions)
            return infoString
            GDALClose(inputDataset)
        } else {
            print("Failed to get dataset info.")
            GDALInfoOptionsFree(infoOptions)
            return nil
            GDALClose(inputDataset)
        }
    }
}
