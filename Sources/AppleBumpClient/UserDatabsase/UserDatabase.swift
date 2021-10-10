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
    var tempsByID: [UUID: DeviceEntry]
    
    @PersistantStorage(key: "userdatabase.detailStorage", defaultValue: [:])
    var detailsByID: [UUID: BUMP.Device]
    
    public func exists(_ vid: UUID)->Bool {
        return tempsByID[vid] != nil
    }
    
    public func entry(for vid: UUID)->DeviceEntry? {
        return tempsByID[vid]
    }
    
    public func reverseLookup(id: UUID)->UUID? {
        return tempsByID.first { item in
            item.value.centralIDs.contains(id) || item.value.peripheralIDs.contains(id)
        }?.key
    }
    
    
    
    public func update(vid: UUID,remotePeer: BKRemotePeer) {
        
        if tempsByID[vid] == nil {
            tempsByID[vid] = DeviceEntry()
        }
        
        if let central = remotePeer as? BKRemoteCentral {
            tempsByID[vid]?.centralIDs.append(central.identifier)
        }
        else if let peripheral = remotePeer as? BKRemotePeripheral {
            tempsByID[vid]?.peripheralIDs.append(peripheral.identifier)
        }
    }
    
    public func details(forDevice vid: UUID)->BUMP.Device? {
        detailsByID[vid]
    }
    
    public func details(forTemp tempID: UUID)->BUMP.Device? {
        if let vid = reverseLookup(id: tempID) {
            return detailsByID[vid]
        }
        return nil
    }
    
    
    public func update(details: BUMP.Device) {
        detailsByID[details.vendorDeviceIdentifier] = details
    }
    
}
