//
//  Communicator.swift
//  RAClientII
//
//  Created by Eric Russell on 10/25/22.
//

import Foundation
import SwiftUI
import Combine
import GRPC
import NIO
import NIOCore
import SwiftProtobuf
import NIOHPACK

public extension Constants {
    static let maxConnectionRetries = 10
}

public struct Communicator {
    let port: Int
    let channel: GRPCChannel
    
    init(port: Int) throws {
        self.port = port
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        self.channel = try GRPCChannelPool.with(
            target: .host("localhost", port: self.port),
            transportSecurity: .plaintext,
            eventLoopGroup: eventLoopGroup
        )
    }
    
    mutating func connect(gameClient: GameClient) async throws {
        // build a fountain of EventLoops
        var retries = 0
        
        while true {
            do {
                while retries < Constants.maxConnectionRetries {
                    try await self.performConnection()
                }
            } catch {
                print("***Couldn't perform the connection", error, "retries:",retries)
                retries += 1
            }
            
            if retries > 10 { break }
        }
    }
    
    private mutating func performConnection() async throws {
        // create a Client
        let gamePortalClient = RABackend_GamePortalAsyncClient(channel: self.channel)
        
        print("GRPC connection initialized")
        
        let myself = self
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            
            let options = CallOptions(customMetadata: HPACKHeaders([("venueID", "primera"), ("activeCharacterID","cire")]),timeLimit: TimeLimit.deadline(NIODeadline.now() + .minutes(15)))
            let connection = gamePortalClient.makeConnectCall(callOptions: options)
             
            group.addTask {
                for try await status in connection.responseStream {
                    print(status)
                    try await MainActor.run {
                        try GameClient.gameClient.venue.update(fromStatus: status)
                    }
                }
                print("end of status loop")
            }
            
            group.addTask {
                while true { try await myself.commandSend(connection: connection) }
            }
            
            group.addTask {
                do {
                    try await myself.sendDefaultCommands()
                } catch {
                    print("Error raised in sendDefaultCommand", error)
                }
            }
            try await group.waitForAll()
        }
        print("ending connection")
    }
    
    private func commandSend(connection: GRPCAsyncBidirectionalStreamingCall<RABackend_GameCommand, RABackend_GameStatus>) async throws {
        let clientCommand = await queue.pop
        
        guard let clientCommand = clientCommand else {
            try await Task.sleep(nanoseconds: 5_000)
            return
        }
        
        let gameCommand = RABackend_GameCommand(clientCommand: clientCommand.0)
        
        try await connection.requestStream.send(gameCommand)
    }
    
    private func sendDefaultCommands() async throws {
        let commands: [ClientCommand] = [
            .connect,
            .wait(10),
//            .face(facing: 4),
            .addWaypoint(destination: VenuePosition(hex: (1,1), x: 10, y: 12), duration: 100 ),
            .wait(6),
//            .face(facing: 0),
//            .wait(3),
//            .face(facing: 1),
//            .wait(3),
//            .face(facing: 2),
//            .wait(3),
//            .face(facing: 3),
//            .wait(3),
//            .face(facing: 4),
//            .wait(3),
//            .face(facing: 5),
            .addWaypoint(destination: VenuePosition(hex: (0,0), x: 20, y: 15), duration: 100),
            .wait(6),
            .addWaypoint(destination: VenuePosition(hex: (1,0), x: 0, y:0), duration: 100),
            .wait(6),
            .addWaypoint(destination: .zero, duration: 100)
            
        ]
        
        for command in commands {
            print("sending:", command)

            if case let .wait(duration) = command {
                try await Task.sleep(nanoseconds: 1_000_000_000 * duration)
                continue
            }
            
            await queue.push((command,nil))
        }
        
        print("Default commands complete")
    }
}
