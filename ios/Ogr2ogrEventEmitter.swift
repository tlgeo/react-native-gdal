@objc(Ogr2ogrEventEmitter)
class Ogr2ogrEventEmitter: RCTEventEmitter {

    static var eventEmitter: Ogr2ogrEventEmitter!

    override init() {
        super.init()
        Ogr2ogrEventEmitter.eventEmitter = self
    }

    override func supportedEvents() -> [String]! {
        return ["onOgr2ogrProgress"]
    }

    @objc override static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
