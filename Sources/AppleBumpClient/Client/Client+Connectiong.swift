//
//  File.swift
//  
//
//  Created by Michael Baron on 10/9/21.
//

import Foundation

extension Client {
    
    public func connectForReverseLookup(id: UUID)async throws ->UUID? {
        if let vid = userDatabase.reverseLookup(id: id) {
            return vid
        }
        if let p = nearbyPeripherals[id] {
            try await connectAndWaitForComplete(to: p)
        }
        return userDatabase.reverseLookup(id: id)
    }
    
    func connect(toPeripheral: BKRemotePeripheral) async throws {
        let _:Void = try await withCheckedThrowingContinuation { cont in
            central.connect(remotePeripheral: toPeripheral) { remotePeripheral, error in
                if error != nil {
                    print("connection error: \(error?.localizedDescription)")
                    cont.resume(with: .failure(Errors.unknown))
                } else {
                    remotePeripheral.delegate = self
                    self.pendingConnections.insert(remotePeripheral.identifier)
                    cont.resume(with: .success(()))
                }
                
            }
        }
    }
    
    func connectAndWaitForComplete(to peripheral: BKRemotePeripheral)async throws {
        try await connect(toPeripheral: peripheral)
        
        
        // wait for conneciton response signalling open conneciton
        let _: Void = try await withCheckedThrowingContinuation({ continuation in
            actor _Continued {
                var value = false
                func fliptoContinued() {
                    value = true
                }
            }
            let continued = _Continued()
            
            let conTask = newDeviceConnection
                .sink { peer in
                    Task {
                        if peer.identifier == peripheral.identifier {
                            await continued.fliptoContinued()
                            continuation.resume(with: .success(()))
                        }
                    }
                }
            
            //timeout
            
            let seconds = 5.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                Task {
                    if !(await continued.value) {
                        print("cenneciton timed out: \(conTask.hashValue)")
                        continuation.resume(with: .failure(Errors.connectionTimedOut))
                    }
                }
            }
        })
    }
    
}

extension Client: BKPeripheralDelegate {
    public func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {

        print("got remote connection request")
        remoteCentral.delegate = self
        
        pendingConnections.insert(remoteCentral.identifier)
        
        do {
            // send back conneciton ident
            var msg = try BUMP.BUMPMessage.fistBump()
            msg.recipient = remoteCentral.identifier
            let binMSG = try JSONEncoder().encode(msg)
            
            
            //Never use syncronise version of this func
            peripheral.sendData(binMSG, toRemotePeer: remoteCentral) { data, remotePeer, error in
                
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
        connectedPeripherals.removeValue(forKey: remotePeripheral.identifier)
        
//        deviceDisconected.send((allSeenDevices[remotePeripheral.identifier])?.device ?? Device(id: remotePeripheral.identifier, name: "Unknown2"))
    }
    
    
}

