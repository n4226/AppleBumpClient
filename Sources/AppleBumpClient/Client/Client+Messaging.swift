//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation

public extension Client {
 
//    func sendToAll(_ message: Message) async {
//        for p in nearbyDevices {
//            _ = await sendMessage(message, to: p.id)
//        }
//    }
//
    ///will set the to device field of the message for caller
    ///id can be a known tmeporary id e.g remote peripheral or central id or device vendor id
    func sendMessage(_ message: BUMP.BUMPMessage,to deviceID: UUID) async -> Bool {
        var peer: BKRemotePeer? = nil
        //determin wether id is temp or perminent -- TODO: right now always assuming temporary
        
        let localId = deviceID
        
        //check for open connection - in either direction
        if let p = connectedPeripherals[localId] {
            peer = p
        }
        
        // if not open one connect
        else if let p = nearbyPeripherals[localId] {
            // connect
            let suc = await connect(toPeripheral: p)
            
            // wait for conneciton response signalling open conneciton
        }
        
        
        //send message
        
        
//        var deviceID = deviceID
//        var message = message
//
//        message.receiveDevice = .init(id: deviceID, name: "-")
//
//
//        // check if vendor id in user datavase
//        if let user = MessageStore.global.userDatabase.lookupUser(vendorID: deviceID),
//           let localDevice = getFirstPeripheral(of: user) {
//            deviceID = localDevice
//            message.receiveDevice = MessageStore.global.userDatabase.lookupDevice(tempID: localDevice)!
//        }
//        else if let user = MessageStore.global.userDatabase.lookupUser(tempID: deviceID),
//                let localDevice = getFirstPeripheral(of: user) {
////                 deviceID = localDevice
//                 message.receiveDevice = MessageStore.global.userDatabase.lookupDevice(tempID: localDevice)!
//             }
//
//        var otherDevice = connectedPeripherals[deviceID]
//
//
//        // connect to device
//        if otherDevice == nil {
//            otherDevice = nearbyPeripherals[deviceID]
//            guard let otherDevice = otherDevice else {
//                print("Tried to talk to a device which could not be found")
//                return false
//            }
//            let connected = await connect(toPeripheral: otherDevice)
//
//            await Task.sleep(600_000_000)
//
//            if !connected {
//                print("device connection faild")
//                return false
//            }
//
//        }
//
//        guard let otherDevice = otherDevice else {
//            print("error of unknown")
//            return false
//        }
//        // send message to device
//        let  data = try! JSONEncoder().encode(message)
////        guard let  else {
////            return false
////        }
////
//        let result: Bool = await withCheckedContinuation { cont in
//            central.sendData(data, toRemotePeer: otherDevice) { data, remotePeer, error in
//                if error != nil {
//                    cont.resume(with: .success(false))
//                }else {
//                    cont.resume(with: .success(true))
//                }
//            }
//        }
//        return result
        return false
    }
    
}

extension Client: BKRemotePeerDelegate {
    public func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        print("data got!")
//
        let message = try? JSONDecoder().decode(BUMP.BUMPMessage.self, from: data)
        if let message = message {
            print("Got message: \(message)")
//            Task {
//                await MessageStore.global.got(message: message)
//            }
        }
    }
    
    
}
