//
//  RAClientIIApp.swift
//  RAClientII
//
//  Created by Eric Russell on 10/20/22.
//

import SwiftUI
import Combine
import GRPC
import NIO
import SwiftProtobuf
import NIOHPACK

public enum Constants {
    public static let numberOfTicksPerSecond: UInt64 = 20
}

extension Constants {
    static var backgroundEffectLevel: CGFloat = -1000
    static var hexagonTileLevel: CGFloat = 0
    static var selectedHexagonTileLevel: CGFloat = 1
    static var playerLevel: CGFloat = 5
    static var facilityLevel: CGFloat = 10
    static var markerLevel: CGFloat = 12
    static var lineLevel: CGFloat = 100
    static var adornerLevel: CGFloat = 101

    static var droppedItemLayerName = "dropped item layer"
    
    static var InteractableAccessRange: CGFloat = 10
    static var movementActionKey = "movementAction"
    static var currentWaypointName = "currentWaypoint"
    static var markerLayerName = "markerLayer"
    
    static var defaultOperationTime:UInt = 60
    static var backgroundAdornerNormalFontSize:CGFloat = 120
    static var backgroundAdornerAlternateFontSize:CGFloat = 85
    static var backgroundAdornerSecondAlternateFontSize: CGFloat = 70
}

var allSubscriptions = Set<AnyCancellable>()

public enum ClientCommand: Codable {
    case nop, report
    case wait(UInt64)
    case connect, close
    case beginOperation, cancelOperation
    case command
    case face(facing: UInt)
    case addWaypoint, abortMovement, abortLastWaypoint
    case consume, use, drop, pickup, equip, unequip
}



@main
struct RAClientIIApp: App {
    var gamePortalClient: RABackend_GamePortalAsyncClient!
    let port: Int = 1964
    
    init() {
        // build a fountain of EventLoops
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        do {
            // open a channel to the gPRC server
            let channel = try GRPCChannelPool.with(
                target: .host("localhost", port: self.port),
                transportSecurity: .plaintext,
                eventLoopGroup: eventLoopGroup
            )
            
            var myself = self

            Task {
                // create a Client
                myself.gamePortalClient = RABackend_GamePortalAsyncClient(channel: channel)
                print("GRPC connection initialized")
                
                try! await withThrowingTaskGroup(of: Void.self) { group in
                    let options = CallOptions(customMetadata: HPACKHeaders([("venueID", "primera"), ("activeCharacterID","cire")]))
                    let connection = myself.gamePortalClient.makeConnectCall(callOptions: options)
                    
                    group.addTask {
                        print("*", terminator: "")
                        for try await status in connection.responseStream {
                            GameClient.gameClient.venue = Venue(fromStatus: status)
                            print("@", terminator: "")
                            print(status)
                        }
                        print("#end", terminator: "")
                    }
                    
                    group.addTask {
                        print("sending Command")
                        var command = RABackend_GameCommand()
                        command.command = .connect
                        command.stringParam = "Second Connection"

                        try! await connection.requestStream.send(command)
                        
                        let status = await connection.status
                        print(status)
                        
                        try await Task.sleep(nanoseconds: 10_000_000_000)
                    }
                    
                    try await group.waitForAll()
                }
                
                print("ending connection")
            }
        } catch {
            print("Couldn’t connect to gRPC server")
        }
    }
    
    var gameClient = GameClient.makeGameClient()
    var gameScene = GameScene(size: CGSize(width: 320, height: 200))

    var body: some Scene {
        WindowGroup {
            MainView()
            .environmentObject(gameClient)
            .environmentObject(gameScene)
        }
    }
}
