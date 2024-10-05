@objc(Gdal)
class Gdal: NSObject {

  @objc(multiply:withB:withResolver:withRejecter:)
  func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    GDALAllRegister();

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
    resolve(a*b)
  }
}
