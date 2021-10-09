
import Foundation
import Combine
import CoreBluetooth



public class Client: ObservableObject {
    
    // MARK: Public Properties
    
    // another paripheral
    public var deviceDisconected = PassthroughSubject<RemoteDevice,Never>()
    public var newDeviceDiscovered = PassthroughSubject<RemoteDevice,Never>()
    
    public var onMessage = PassthroughSubject<BUMP.BUMPMessage,Never>()
    
    @Published
    public private(set) var nearbyDevices: [DeviceDiscovery] = []
    
    
    
    // MARK: Private Properties
    
    @Published
    private(set) var configuration: Configuration?
    let peripheral = BKPeripheral()
    let central = BKCentral()
    var tasks: [AnyCancellable] = []
    
  
    
    var lastDescovery: [BKDiscovery] = []
    var scanning = false
    var attemptingToScan = false
    
    var userDatabase = UserDatabase()
    
    var newDevicesFound = PassthroughSubject<[DeviceDiscovery],Never>()
    
    
    //storage lookup
    var allSeenDevices: [UUID: DeviceDiscovery] = [:]
    
    var nearbyPeripherals: [UUID: BKRemotePeripheral] = [:]
    var connectedPeripherals: [UUID: BKRemotePeripheral] = [:]
    var connectedCentrals: [UUID: BKRemoteCentral] = [:]
    
    
    
    public init () {
        
        configurePeripheral()
        configureCentral()
        
        
//        restartCommunication(prefs: Settings.global.userPrefs)
        $configuration.sink { config in
            self.stopScan()
            if let config = config {
                self.restartCommunication(config: config)
//                let seconds = 0.1
//                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.startScanning()
//                }
            }
        }.store(in: &tasks)
        
        newDevicesFound
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { discoveries in
                self.nearbyDevices = discoveries
            }
            .store(in: &tasks)
        
        
//
    }
    
 
    
    public func set(config: Configuration) {
        self.configuration = config
    }
    
    
    
//    func getFirstPeripheral(of user: User)->UUID? {
//        let devices = MessageStore.global.userDatabase.devices(for: user)
//
//        for dev in devices {
//            for id in dev.knownTemporaryIdentifers {
//                if nearbyPeripherals[id] != nil {
//                    return id
//                }
//            }
//        }
//        return nil
//    }
    

   
    
//    public func getPublicDeviceId() {
//        return central.
//    }
    
}


