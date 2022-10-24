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
import NIOCore
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
    case addWaypoint(destination: VenuePosition, duration: UInt64)
    case abortMovement, abortLastWaypoint
    case consume(itemID: Item.ID)
    case use(itemID: Item.ID)
    case drop(itemID: Item.ID)
    case pickup(droppedItemID: DroppedItem.ID)
    case equip(itemID: Item.ID)
    case unequip(itemID: Item.ID)
}


var queue = CommandQueue<ClientCommand, ClientCommand>() {
    print($0 as Any)
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
                    
                    let options = CallOptions(customMetadata: HPACKHeaders([("venueID", "primera"), ("activeCharacterID","cire")]),timeLimit: TimeLimit.deadline(NIODeadline.now() + .minutes(15)))
                    let connection = myself.gamePortalClient.makeConnectCall(callOptions: options)
                    
                    group.addTask {
                        print("*", terminator: "")
                        for try await status in connection.responseStream {
                            await MainActor.run {
                                GameClient.gameClient.venue.update(fromStatus: status)
                                print("@", terminator: "")
                            }
                            print(status)

                        }
                        print("#end", terminator: "")
                    }
                    
                    group.addTask {
                        while true {
                            let clientCommand = await queue.pop
                            
                            guard let clientCommand = clientCommand else {
                                try! await Task.sleep(nanoseconds: 5_000)
                                continue
                            }
                            
                            let gameCommand = RABackend_GameCommand(clientCommand: clientCommand.0)
                            
                            try! await connection.requestStream.send(gameCommand)
                        }
                    }
                    
                    group.addTask {
                        let commands: [ClientCommand] = [
                            .connect,
                            .wait(10),
                            .face(facing: 4),
                            .addWaypoint(destination: VenuePosition(hex: (1,1), x: 0, y: 0),duration: UInt64(5.seconds) ),
//                            .report,
                        ]
                        
                        for command in commands {
                            if case let .wait(duration) = command {
                                try! await Task.sleep(nanoseconds: 1_000_000_000 * duration)
                                continue
                            }
                            
                            await queue.push((command,nil))
                        }
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
            .task {
                GameClient.gameClient = gameClient
                gameScene.gameClient = gameClient
                GameClient.gameScene = gameScene
                
                await startup()
                
                gameClient.start()
            }
            .environmentObject(gameClient)
            .environmentObject(gameScene)

        }
    }
    
    func startup() async -> Game {
//        game.characterSetup()
        let game = await Game()
        Game.game = game
        
        // needs to be before other initialization so that ticks and scheduling is available.
        game.heartbeat = Heartbeat(beatNotifier: game)
        try! game.heartbeat.start()
        Game.game.oneTimeSetup()
        
        //        self.characters = Character.Characters()
        game.heartbeat = Heartbeat(beatNotifier: game)
        
        await MainActor.run {
            gameClient.venue = game.venue
        }
        await gameScene.setupScene()
        
        await GameClient.gameScene.initialize()
        gameClient.venue.recordAllCharacters()
        
        return Game.game
    }
}
