//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation

extension BUMP.BUMPMessage {
    
    static func pingResponse()->BUMP.BUMPMessage {
        BUMP.BUMPMessage(type: .pingResponse, sender: BUMP.Device.this.id, recipient: UUID(), sendDate: Date(), payoload: Data())
    }
    
    static func ident()throws->BUMP.BUMPMessage {
        BUMP.BUMPMessage(type: .ident, sender: BUMP.Device.this.id, recipient: UUID(), sendDate: Date(), payoload: try JSONEncoder().encode(BUMP.Device.this))
    }
    
    static func fistBump()throws->BUMP.BUMPMessage {
        var m = try BUMP.BUMPMessage.ident()
        m.type = .fistBump
        return m
    }
    
}
