//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation

public extension Client {
 
//
//
    ///will set the to device field of the message for caller
    ///id can be a known tmeporary id e.g remote peripheral or central id or device vendor id
    func sendMessage(_ message: BUMP.BUMPMessage,to deviceID: UUID) async throws {
        var message = message
        var peer: BKRemotePeer? = nil
        //determin wether id is temp or perminent -- TODO: right now always assuming temporary
        
        //TODO: just missing id lookup to either vid, central or peripheral id not just peripheral id
        //TODO: if deviceid is a nearby peripheral check if presistablished connection exists with its asociated central
        
        let vid = deviceID
        let localId = deviceID
        
        //vid
        if let entry = userDatabase.entry(for: vid) {
            //check for peripheral connections
            if let p = connectedPeripherals.first(where: { v in
                entry.peripheralIDs.contains(v.key)
            })?.value {
                peer = p
            }
            //check for central connections
            else if let p = connectedCentrals.first(where: { v in
                entry.centralIDs.contains(v.key)
            })?.value {
                peer = p
            }
            
            //establish new peer connection
            else if let p = nearbyPeripherals.first(where: { v in
                entry.centralIDs.contains(v.key)
            })?.value {
                try await connectAndWaitForComplete(to: p)
                peer = p
            }
            
            
            message.recipient = vid
        }
        //tempid
        else {
            //check for open connection - in either direction
            if let p = connectedPeripherals[localId] {
                peer = p
            }
            else if let p = connectedCentrals[localId] {
                peer = p
            }
            // if not open one connect
            else if let p = nearbyPeripherals[localId] {
                // connect
                try await connectAndWaitForComplete(to: p)
                peer = p
                
            }
            
            if let venderID = userDatabase.reverseLookup(id: localId) {
                message.recipient = venderID
            }else {
                print("failed to find recipent device id")
            }
        }
        
        
        //send message
        guard let peer = peer else {
            throw Errors.deviceNotFound
        }
        
        //TODO: replace recepient id with vid of device sending to
       
        
        let data = try JSONEncoder().encode(message)
        
        try await _send(data: data, to: peer)
        
        return
    }
    
    ///remoPeer can be a central or peripheral
    internal func _send(data: Data, to remotePeer: BKRemotePeer) async throws {
        let _: Void = try await withCheckedThrowingContinuation { cont in
            if let _ = remotePeer as? BKRemotePeripheral {
                central.sendData(data, toRemotePeer: remotePeer) { data, remotePeer, error in
                    if error != nil {
                        cont.resume(with: .failure(Errors.failedToSend))
                    }else {
                        cont.resume(with: .success(()))
                    }
                }
            }else {
                peripheral.sendData(data, toRemotePeer: remotePeer) { data, remotePeer, error in
                    if error != nil {
                        cont.resume(with: .failure(Errors.failedToSend))
                    }else {
                        cont.resume(with: .success(()))
                    }
                }
            }
        }
    }
    
    func breadcastToAllNearby(_ message: BUMP.BUMPMessage) async throws {
          for p in nearbyDevices {
              _ = try await sendMessage(message, to: p.id)
          }
      }
    
}

