@objc(Gdal)
class Gdal: NSObject {

    @objc(multiply:withB:withResolver:withRejecter:)
    func multiply(
        a: Float, b: Float, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock
    ) {
        GDALAllRegister()

        let driverCount = GDALGetDriverCount()

        print("Available GDAL Drivers:")

        for i in 0..<driverCount {
            // Get the driver by index
            if let driver = GDALGetDriver(i) {
                // Get the driver name
                if let driverName = GDALGetDriverShortName(driver) {
                    // Convert the C-string to Swift String
                    let name = String(cString: driverName)
                    print("Driver \(i): \(name)")
                }
            }
        }
        resolve(a * b)
    }

    @objc(RNOgr2ogr:withResolver:withRejecter:)
    func RNOgr2ogr(args: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        ogr2ogr_translate(args: args)
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

    func ogr2ogr_translate(args: [String]) {
        let inputDGN = args[3]
        let outputGeoJSON = args[2]
        GDALAllRegister()

        // Open input dataset
        guard
            let inputDataset = GDALOpenEx(
                inputDGN.cString(using: .utf8), UInt32(GDAL_OF_VECTOR), nil, nil, nil)
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
                outputGeoJSON.cString(using: .utf8),  // Output file
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
}
