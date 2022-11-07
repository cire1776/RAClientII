//
//  MainView.swift
//  Client
//
//  Created by Eric Russell on 4/9/22.
//

import SwiftUI
import SpriteKit

///
class SKSceneObservable: ObservableObject {
    let scene: SKScene
    
    init (scene: SKScene) {
        self.scene = scene
    }
}

extension Constants {
    static let sideWindowWidth: CGFloat = 400
}

struct MainView: View {
    @EnvironmentObject var scene: GameScene
    @EnvironmentObject var gameClient: GameClient
    @EnvironmentObject var clock: Game.Clock
    
    @State var sideWindowSize: CGSize = CGSize(width: Constants.sideWindowWidth, height: 200)
    @State var screenSelected = "Inventory"
    
    @State var tickDisplayString = "N/A"
    
    private var venueMap: SKNode? {
        return scene.childNode(withName: "HexagonMapNode")
    }
        
    var sideWindowTitle: String {
        guard let player = gameClient.player else { return "" }
        return player.slice.displayName
    }
    
    var body: some View {
        GeometryReader { gp in
            ZStack(alignment: .topLeading) {
                VenueMap()
                
                ZStack {
                    Window(title: (gameClient.venue?.name ?? ""),
                           position: CGPoint.zero,
                           size: Binding.constant(CGSize(width: 250, height: 250))
                    ) {
                        VStack {
                            ScrollView([.horizontal,.vertical]) {
                                Image(uiImage: gameClient.venue.minimap ?? scene.minimap! )
                                .resizable()
                                .scaledToFill()
                                .frame(width: 400, height: 400, alignment: .center)
                            }
                    }
                        .padding(10)
                    }
                    .border(.black,width: 3)
                    
                    Window(title: self.sideWindowTitle,
                           position: CGPoint(x:-(sideWindowSize.width) + 3, y: 0),
                           size: $sideWindowSize
                    ) {
                        TabView(selection: $screenSelected) {
                            ScrollView(.vertical, showsIndicators: false) {
//                                ItemsView(player: self.gameClient.player)
//                                MemesView(player: self.gameClient.player)
                                Spacer()
                            }
                            .tag("Inventory")
                            
                            ScrollView(.vertical, showsIndicators: false) {
//                                AttributesView(player: self.gameClient.player)
//                                SkillsView(player: self.gameClient.player)
                                Spacer()
                            }
                            .tag("Attributes & Skills")
                            
                            ScrollView(.vertical, showsIndicators: false) {
//                                EndorsementsView(player: self.gameClient.player)
                                Spacer()
                            }
                            .tag("Endorsements")
                        }
                        .tabViewStyle(.page)
                    }
                    .border(.black,width: 3)
                    .onChange(of: screenSelected) { screen in
                        print("screen:", screen)
                    }

//                    BottomWindow(title: "Communication", height: 250) {
//                        VStack {
//                            Text("Content")
//                        }
//                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .statusBar(hidden: true)
            .padding(.top, 0)
            .onPreferenceChange(ContentSizePreferenceKey.self) { size in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.sideWindowSize = CGSize(width: 400, height: gp.size.height - size.height - 40)
                }
            }
        }
//        .task {
//            GameClient.gameClient = gameClient
//            
//            GameClient.gameScene = scene
//            scene.gameClient = gameClient
//            
//            let game: Game
//            
//            do {
//                game = try await GameLoader().load(server: server as! MockServer)
//                
//                initializeGameClock(game: game)
//                GameSaver.scheduleSave(game: game)
//            } catch {
//                print("**** Unable to load data:",error)
//                game = Game(server: server)
//                
//                Game.game = game
//                server.game = game
//               
//                // needs to be before other initialization so that ticks and scheduling is available.
//                game.gameClock = Game.GameClock(game: game, initialTick: game.initialTick)
//                initializeGameClock(game: game)
//                
//                game.oneTimeSetup()
//                game.characterSetup()
//            }
//                            
//            gameClient.start()
//            
//            if game.changed {
//                try! game.save()
//            }
//        }
    }
        
    struct ContentSizePreferenceKey: PreferenceKey {
        typealias Value = CGSize

        static var defaultValue: CGSize = .zero
        
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
    
    struct TitlePreferenceKey: PreferenceKey {
        typealias Value = String
        
        static var defaultValue = ""
        
        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
    }
    
    struct SizeModifier: View {
        var body: some View {
            GeometryReader { gp in
                Color.clear.preference(key: ContentSizePreferenceKey.self, value: gp.size)
            }
        }
    }
}

extension MainView {
   
}

struct ContentView_Previews: PreviewProvider {
    static var gameClient = GameClient()
    static var gameScene = GameScene(size: CGSize(width: 320, height: 200))

    static var scene = SKScene(size: CGSize(width: 300*64, height: 200*64))
    
    static var previews: some View {
        MainView()
//        .environmentObject(SKSceneObservable(scene: scene))
        .environmentObject(gameScene)
        .environmentObject(gameClient)
        .previewInterfaceOrientation(.landscapeRight)
    }
}
