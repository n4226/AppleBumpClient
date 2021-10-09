//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation

extension Client {
    
    func connect(toPeripheral: BKRemotePeripheral) async -> Bool {
        let result: Bool = await withCheckedContinuation { cont in
            central.connect(remotePeripheral: toPeripheral) { remotePeripheral, error in
                if error != nil {
                    print("connection error: \(error?.localizedDescription)")
                    cont.resume(with: .success(false))
                } else {
                    remotePeripheral.delegate = self
                    self.connectedPeripherals[remotePeripheral.identifier] = remotePeripheral
                    cont.resume(with: .success(true))
                }
                
            }
        }
        return result
    }
    
}

extension Client: BKPeripheralDelegate {
    public func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {

        print("got remote connection request")
        remoteCentral.delegate = self
        connectedCentrals[remoteCentral.identifier] = remoteCentral
        
        do {
            // send back conneciton ident
            var msg = try BUMP.BUMPMessage.ident()
            msg.recipient = remoteCentral.identifier
            let binMSG = try JSONEncoder().encode(msg)
            
            
            //Never use syncronise version of this func
            let suc = peripheral.sendData(binMSG, toRemotePeer: remoteCentral) { data, remotePeer, error in
            }
        } catch {
            print("connection handshake failed")
        }
    }
    
    public func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        remoteCentral.delegate = nil
        connectedCentrals.removeValue(forKey: remoteCentral.identifier)
    }
}

extension Client: BKCentralDelegate {
    public func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        remotePeripheral.delegate = nil
//        connectedPeripherals.removeValue(forKey: remotePeripheral.identifier)
//        deviceDisconected.send((allSeenDevices[remotePeripheral.identifier])?.device ?? Device(id: remotePeripheral.identifier, name: "Unknown2"))
    }
    
    
}

