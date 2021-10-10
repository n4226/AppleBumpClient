//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation

public class UserDatabase {
    
    public struct DeviceEntry: Codable {
        var peripheralIDs: [UUID] = []
        var centralIDs: [UUID] = []
    }
    
    @PersistantStorage(key: "userdatabase.tempStorage", defaultValue: [:])
    var tempsById: [UUID: DeviceEntry]
    
    
    public func exists(_ vid: UUID)->Bool {
        return tempsById[vid] != nil
    }
    
    public func entry(for vid: UUID)->DeviceEntry? {
        return tempsById[vid]
    }
    
    public func update(vid: UUID,remotePeer: BKRemotePeer) {
        
        if tempsById[vid] == nil {
            tempsById[vid] = DeviceEntry()
        }
        
        if let central = remotePeer as? BKRemoteCentral {
            tempsById[vid]?.centralIDs.append(central.identifier)
        }
        else if let peripheral = remotePeer as? BKRemotePeripheral {
            tempsById[vid]?.peripheralIDs.append(peripheral.identifier)
        }
    }
    
}
