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
        ogr2ogr_translate(inputDGN: args[3], outputGeoJSON: args[2])
        resolve("abc")
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

    func ogr2ogr_translate(inputDGN: String, outputGeoJSON: String) {
        // guard let inputDGNUrl = URL(string: inputDGN), let outputGeoJSONUrl = URL(string: outputGeoJSON) else {
        //   print("Invalid URL strings.")
        //   return
        // }

        

        // inputDGNUrl.startAccessingSecurityScopedResource()
        // outputGeoJSONUrl.startAccessingSecurityScopedResource()
        // Register all drivers
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

        // Prepare arguments for GDALVectorTranslate
        //        var options = [UnsafeMutablePointer<CChar>?]()
        //
        ////        options.append(UnsafeMutablePointer(mutating: "-f"))  // Output format
        ////        options.append(UnsafeMutablePointer(mutating: "GeoJSON"))
        //        options.append(UnsafeMutablePointer(mutating: "-t_srs"))
        //        options.append(UnsafeMutablePointer(mutating: "\"EPSG:4326\""))
        //        options.append(UnsafeMutablePointer(mutating: "-s_srs"))
        //        options.append(UnsafeMutablePointer(mutating: "+proj=tmerc +lat_0=0 +lon_0=105 +k=0.9999 +x_0=500000 +y_0=0 +ellps=WGS84 +towgs84=-191.90441429,-39.30318279,-111.45032835,0.00928836,-0.01975479,0.00427372,0.252906278 +units=m +no_defs"))
        //
        //        options.append(UnsafeMutablePointer(mutating: "-overwrite"))  // Enable overwriting
        ////        options.append(UnsafeMutablePointer(mutating: "Layer #0"))
        //
        //        options.append(UnsafeMutablePointer(mutating: "LAYER=elements"))
        //        options.append(nil)
        let optionsArray = [
            "-f", "Mbtiles",
            "-dsco", "MINZOOM=0", "-dsco", "MAXZOOM=18",
            "-t_srs", "+proj=longlat +datum=WGS84 +no_defs +type=crs",
            //                            "-s_srs", "+proj=tmerc +lat_0=0 +lon_0=105 +k=0.9999 +x_0=500000 +y_0=0 +ellps=WGS84 +towgs84=-191.90441429,-39.30318279,-111.45032835,0.00928836,-0.01975479,0.00427372,0.252906278 +units=m +no_defs"
            "-s_srs",
            "+proj=tmerc +lat_0=0 +lon_0=105 +k=0.9999 +x_0=500000 +y_0=0 +ellps=WGS84 +towgs84=-191.90441429,-39.30318279,-111.45032835,0.00928836,-0.01975479,0.00427372,0.252906278 +units=m +no_defs",
            layerName,
        ]
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
