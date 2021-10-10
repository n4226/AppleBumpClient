//
//  UMPDataTypes.swift
//  OfflineChat
//
//  Created by Michael Baron on 10/5/21.
//

import Foundation
import Combine
import UIKit
import SwiftUI

public enum BUMP {
    
    
    public struct Device: Codable, Identifiable, Hashable {
        // device vendor id
        public var id: UUID {vendorDeviceIdentifier}
        public var name: String
        public var vendorDeviceIdentifier: UUID
        public var prefs: UserPreferences
        public var joinDate: Date
        public var os: String
        public var osVersion: String
        public var program: UUID
        public var programVersion: String

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        public static let defualtName = "unknown"
        
        @PersistantStorage(key: "bump.DefaultDevice", defaultValue: Device(name: "No Name", vendorDeviceIdentifier: UIDevice.current.identifierForVendor!, prefs: UserPreferences(preferedAccentColor: Color(SwiftUI.Color.accentColor.cgColor ?? CGColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1)), appSpacificConfig: Data()), joinDate: Date(), os: UIDevice.current.systemName, osVersion: UIDevice.current.systemVersion, program: UUID(), programVersion: "ERR"))
        public static var this: Device
        
    }
    
    public struct Color: Codable {
        public init(r: Float, g: Float, b: Float) {
            self.r = r
            self.g = g
            self.b = b
        }
        
        public var r: Float
        public var g: Float
        public var b: Float
        
        public init(_ cgColor: CGColor) {
            if cgColor.numberOfComponents < 3 {
                r = 0
                g = 0
                b = 0
                return
            }
            r = Float(cgColor.components![0])
            g = Float(cgColor.components![1])
            b = Float(cgColor.components![2])
        }
        
        public var asCG: CGColor {
            CGColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
        }
    }
        
    public struct UserPreferences: Codable {
        public var preferedAccentColor: Color
        public var appSpacificConfig: Data
    }
    
    
    public struct BUMPMessage: Codable {
        public init(type: BUMP.BUMPMessage.MessageType, sender: UUID, recipient: UUID, sendDate: Date, payoload: Data) {
            self.type = type
            self.sender = sender
            self.recipient = recipient
            self.sendDate = sendDate
            self.payoload = payoload
        }
        
        public enum MessageType: Int, Codable {
            case ping
            case pingResponse
            case fistBump
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
        public var payoload: Data
    }
    
    
}
