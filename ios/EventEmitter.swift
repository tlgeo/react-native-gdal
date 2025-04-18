@objc(EventEmitter)
class EventEmitter: RCTEventEmitter {

    static var eventEmitter: EventEmitter!

    override init() {
        super.init()
        EventEmitter.eventEmitter = self
    }

    override func supportedEvents() -> [String]! {
        return ["onOgr2ogrProgress"]
    }

    @objc override static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
