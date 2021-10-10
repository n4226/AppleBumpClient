//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation
import Combine

public extension Client {
    
    struct RemoteDevice {
        public var name: String
        internal var peer: BKRemotePeer
        
//        public func hash(into hasher: inout Hasher) {
//            hasher.combine(ObjectIdentifier(peer))
//        }
//        public static func ==(lhs: Self, rhs: Self)->Bool {
//            return lhs.peer === rhs.peer
//        }
//
        static let defaultName = "No Name"
    }
    
    struct DeviceDiscovery: Identifiable, Hashable, Equatable {
        public var RSSI: Int
        
        public var id: UUID
        public var name: String
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        public static func ==(lhs: Self, rhs: Self)->Bool {
            return lhs.id == rhs.id
        }
        
        public static func from(_ discovery: BKDiscovery)->DeviceDiscovery {
//            return DeviceDiscovery(RSSI: discovery.RSSI, device: Client.RemoteDevice(name: discovery.localName ?? RemoteDevice.defaultName, peer: discovery.remotePeripheral))
            return DeviceDiscovery(RSSI: discovery.RSSI, id: discovery.remotePeripheral.identifier, name: discovery.localName ?? RemoteDevice.defaultName)
        }
    }
    
}
