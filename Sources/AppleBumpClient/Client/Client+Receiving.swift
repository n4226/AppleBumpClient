//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation


extension Client: BKRemotePeerDelegate {
    public func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        print("data got!")
//
        let message = try? JSONDecoder().decode(BUMP.BUMPMessage.self, from: data)
        if let message = message {
            print("Got message: \(message)")
            print("payload: \(String(data: message.payoload, encoding: .utf8) ?? "{not properly formatted}")")
            
            Task {
                await procces(message: message, from: remotePeer)
            }
//            Task {
//                await MessageStore.global.got(message: message)
//            }
        }
    }
    
    private func procces(message: BUMP.BUMPMessage, from peer: BKRemotePeer) async {
        
        do {
        switch message.type {
        case .ping:
            //send pingresponse
            let response = BUMP.BUMPMessage.pingResponse()
            try await sendMessage(response, to: peer.identifier)
            break
        case .pingResponse:
            
            
            
            break
        case .fistBump:
            
            // add data received to user database
            // record information
            if let deviceDetails = try? JSONDecoder().decode(BUMP.Device.self, from: message.payoload) {
                userDatabase.update(details: deviceDetails)
            }
            userDatabase.update(vid: message.sender,remotePeer: peer)
            
            //send back ident message
            let response = try BUMP.BUMPMessage.ident()
            let binResponse = try JSONEncoder().encode(response)
            try await _send(data: binResponse,to: peer)
            
            // if this marks the beginning of a connection mark this device as fully connected
            if pendingConnections.contains(peer.identifier), peer is BKRemotePeripheral {
                pendingConnections.remove(peer.identifier)
                connectedPeripherals[peer.identifier] = (peer as! BKRemotePeripheral)
                newDeviceConnection.send(peer)
            }
            
            break
        case .incompatible:
            break
        case .identRequest:
            break
        case .ident:
            
            // add data received to user database
            // record information
            if let deviceDetails = try? JSONDecoder().decode(BUMP.Device.self, from: message.payoload) {
                userDatabase.update(details: deviceDetails)
            }
            userDatabase.update(vid: message.sender,remotePeer: peer)
                
                
                
            
            // if this marks the beginning of a connection mark this device as fully connected
            if pendingConnections.contains(peer.identifier), peer is BKRemoteCentral {
                pendingConnections.remove(peer.identifier)
                connectedCentrals[peer.identifier] = (peer as! BKRemoteCentral)
                newDeviceConnection.send(peer)
            }
                
            
            break
        case .deviceStatusRequest:
            break
        case .deviceStatus:
            break
        case .terminate:
            break
        case .stdPayload:
            break
        }
        }
        catch {
            print("error porccesing message")
        }
        
        onMessage.send(message)
    }
    
}
