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
    
    var gameClient = GameClient.makeGameClient()
    var gameScene = GameScene(size: CGSize(width: 320, height: 200))
    
    var body: some Scene {
        WindowGroup {
            MainView()
            .task { await startup() }
            .environmentObject(gameClient)
            .environmentObject(gameScene)
        }
    }
    
    init() {
        let port = self.port
        let gameClient = self.gameClient
        
        Task {
            do {
                var communicator = try Communicator(port: port)
                try await communicator.connect(gameClient: gameClient)
            } catch {
                print("***Unable to connect to gRPC server")
            }
        }
    }
    
    func startup() async {
        await MainActor.run {
            GameClient.gameClient = gameClient
            gameScene.gameClient = gameClient
            GameClient.gameScene = gameScene
        }
        
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
        gameClient.venue.registerAllCharacters()
        
        gameClient.start()
    }
}
