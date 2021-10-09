//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation

extension Client {
    
    public struct Configuration {
        public init(displayName: String, broadcast: Bool) {
            self.displayName = displayName
            self.broadcast = broadcast
        }
        
        var displayName: String
        var broadcast: Bool
    }
    
    func configurePeripheral() {
        peripheral.delegate = self
        
        
    }
    
    func startPeripheral(name: String) throws {
        let localName = name
        let configuration = BKPeripheralConfiguration(dataServiceUUID: BUMPConstants.serviceUUID, dataServiceCharacteristicUUID:     BUMPConstants.characteristicUUID, localName: localName)
        try peripheral.startWithConfiguration(configuration)
        
    }
        
    func configureCentral() {
        central.delegate = self
        central.addAvailabilityObserver(self)
    }
    
    func startCentral() throws {
        let configuration = BKConfiguration(dataServiceUUID: BUMPConstants.serviceUUID, dataServiceCharacteristicUUID: BUMPConstants.characteristicUUID)
        try central.startWithConfiguration(configuration)
    }
    
    
    func restartCommunication(config: Configuration) {
        
        try? peripheral.stop()
        try? central.stop()
        
        do {
            if config.broadcast {
                try startPeripheral(name: config.displayName)
            }
            try startCentral()
        }
        catch {
            print("error configureing coms: \(error.localizedDescription)")
        }
    }
    
}
