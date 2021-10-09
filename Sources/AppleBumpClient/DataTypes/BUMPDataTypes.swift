//
//  UMPDataTypes.swift
//  OfflineChat
//
//  Created by Michael Baron on 10/5/21.
//

import Foundation
import Combine
import UIKit

public enum BUMP {
    
    
    public struct Device: Codable, Identifiable, Hashable {
        // device vendor id
        public var id: UUID {vendorDeviceIdentifier}
        var name: String
        var vendorDeviceIdentifier: UUID
        var prefs: UserPreferences
        var joinDate: Date
        var os: String
        var osVersion: String
        var program: UUID
        var programVersion: String

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        static let defualtName = "unknown"
        
        @PersistantStorage(key: "bump.DefaultDevice", defaultValue: Device(name: "", vendorDeviceIdentifier: UIDevice.current.identifierForVendor!, prefs: UserPreferences(preferedAccentColor: Color(r: 0, g: 0, b: 0), appSpacificConfig: Data()), joinDate: Date(), os: UIDevice.current.systemName, osVersion: UIDevice.current.systemVersion, program: UUID(), programVersion: "ERR"))
        public static var this: Device
        
    }
    
    public struct Color: Codable {
        var r: UInt8
        var g: UInt8
        var b: UInt8
    }
        
    public struct UserPreferences: Codable {
        var preferedAccentColor: Color
        var appSpacificConfig: Data
    }
    
    
    public struct BUMPMessage: Codable {
        public init(type: BUMP.BUMPMessage.MessageType, sender: UUID, recipient: UUID, sendDate: Date, Payoload: Data) {
            self.type = type
            self.sender = sender
            self.recipient = recipient
            self.sendDate = sendDate
            self.Payoload = Payoload
        }
        
        public enum MessageType: Int, Codable {
            case ping
            case pingResponse
            case incompatible
            case identRequest
            case ident
            case deviceStatusRequest
            case deviceStatus
            case terminate
            case stdPayload
        }
        public var type: MessageType
        public var sender: UUID
        public var recipient: UUID
        public var sendDate: Date
        public var Payoload: Data
    }
    
    
}
