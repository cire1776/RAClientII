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
    public static let worldWidth = 100
    public static let worldHeight = 100
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

var queue = CommandQueue<ClientCommand, ClientCommand>() {
    print($0 as Any)
}

@main
struct RAClientIIApp: App {
    var gamePortalClient: RABackend_GamePortalAsyncClient!
    let port: Int = 1964
    
    var gameClient = GameClient.makeGameClient()
    var gameScene = GameScene(size: CGSize(width: 320, height: 200))
    var game = Game()
    
    var body: some Scene {
        WindowGroup {
            MainView()
            .environmentObject(gameClient)
            .environmentObject(gameScene)
            .environmentObject(game.clock)
        }
    }
    
    init() {
        let port = self.port
        let gameClient = self.gameClient
        let myself = self
        
        Task {
            await myself.startup()
            do {
                var communicator = try Communicator(port: port)
                try await communicator.connect(gameClient: gameClient)
            } catch {
                print("***Unable to connect to gRPC server")
            }
        }
    }
    
    func startup() async {
        Game.game = game
        
        await MainActor.run {
            GameClient.gameClient = gameClient
            GameClient.gameScene = gameScene
            gameScene.gameClient = gameClient
        }
        
        // needs to be before other initialization so that ticks and scheduling is available.
        await game.clock.set(heartbeat: Heartbeat(beatNotifier: game.clock))
        try! await game.clock.heartbeat.start()
        
        Game.game.oneTimeSetup()
        
        //        self.characters = Character.Characters()
        
        await MainActor.run {
            gameClient.venue = game.venue
        }
        await gameScene.setupScene()
        
        await GameClient.gameScene.initialize()
        gameClient.venue.registerAllCharacters()
    }
}
