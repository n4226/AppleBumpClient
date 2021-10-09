//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation

public extension Client {
    
    func startScanning() {
        if scanning {
            stopScan()
//            return
        }
        scanning = true
        print("starting scan")
        central.scanContinuouslyWithChangeHandler({ [self] changes, discoveries in

            let typedDiscoveries =
            discoveries.map { discovery -> DeviceDiscovery in
                    return DeviceDiscovery.from(discovery)
//                    DeviceDiscovery(device: Device(id: .init() ,name: "no name"), RSSI: 0)
                }


            discoveries.forEach { disc in
//
                let device = DeviceDiscovery.from(disc)
                
                nearbyPeripherals[device.id] = disc.remotePeripheral
//
//                MessageStore.global.userDatabase.addOrUpdateUser(for: device)
//
//                if allSeenDevices[disc.remotePeripheral.identifier] == nil {
//                    newDeviceDiscovered.send(device)
//                }
//
//                self.nearbyPeripherals[disc.remotePeripheral.identifier] = disc.remotePeripheral
//                allSeenDevices[disc.remotePeripheral.identifier] = .from(disc)
//
            }

            newDevicesFound.send(typedDiscoveries)
            
            
        }, stateHandler: { newState in
            if newState == .stopped {
                self.scanning = false
            }
        }, duration: 3, inBetweenDelay: 0.5, updateDuplicates: true) { error in
            print("scan error: \(error.localizedDescription)")
            self.attemptingToScan = true
        }
    }
    
    
    
    func stopScan() {
        if !scanning {
            return
        }
        print("stoping scan")
        central.interruptScan()
        scanning = false
    }
}


extension Client: BKAvailabilityObserver {
    
    
    public func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        switch availability {
        case .available:
            print("ble available")
            if scanning == true && attemptingToScan == true {
                attemptingToScan = false
                scanning = false
                startScanning()
            }
        case .unavailable(let cause):
            print("ble un available \(cause.hashValue)")
        }
    }
    
    public func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        
    }
    
}
