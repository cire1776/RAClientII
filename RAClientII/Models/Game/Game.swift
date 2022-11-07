//
//  Game.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/15/22.
//

import Foundation
import OrderedCollections

#if CLIENT
let sharedGame = Game.game!
#endif


public class Game: ObservableObject {
    static var game: Game!
//    static var environment: Game.Environment!
    
    static var venues: [Venue.ID : Venue] = [
        "primera": Venue(named: "Primera", description: "The first place"),
    ]
    
    static func add(venue: Venue) {
        print("Adding Venue")
        venues[venue.id] = venue
    }
    
    static var characters = Character.Characters()
    
//    fileprivate static var gameURL: URL {
//        let folderURL = try? FileManager.default.url(
//            for: .documentDirectory,
//            in: .userDomainMask,
//            appropriateFor: nil,
//            create: false
//        )
//
//        return folderURL!.appendingPathComponent("game.json")
//    }
//
    static var itemTypes = [ItemType.ID : ItemType]()
    
    static func add(_ itemTypes: [ItemType]) {
        for itemType in itemTypes {
            self.itemTypes[itemType.id] = itemType
        }
    }
    
    static var items = [Item.ID: Item]()
    
    // Server Mock Objects
    var venueID: Venue.ID = "Uninitialized"
    var venue: Venue? {
        Game.venues[venueID]
    }
    
//    var currentOperation: Game.Operation? = nil
//    var cancelOperationAfterPerform = false
    
    var clock = Game.Clock()
    
    @Published var ticks: UInt64 = 0
    
    var playerID: Character.ID
    
    var player: Character? {
        Self.characters.data[playerID]
    }
    
//    var operationResults: Operation.Result! = nil
    
    var changed = false
    
    private var holdTicks: UInt = 0
    
    var savingEvent: (String, UInt) = ("",0)
    
    init() {
        self.playerID = "cire"
        
        restoreItemTypes()
        
        triggerLazy(loadEverything: true)
    }
    
    public subscript(source: ModelType, index: String) -> AnyObject? {
        get throws {
            switch source {
            case .venue:
                return Game.venues[index]
            case .item:
                return Game.items[index]
            case .itemType:
                return Game.itemTypes[index]
            default:
                throw RAError.Unknown(reason:"@@@reason: Unknown ModelType")
            }
        }
    }
    
    private func triggerLazy(loadEverything: Bool = false) {
//        Endorsement.setupRegisteredEndorsements()
//        Game.environment = Game.Environment()
        
        // lazy evaluations,
        
        if loadEverything {
            print("starting venues:", Game.venues.count)
            
//            _ = Facilities.setupOperations
            
            self.venueID = Game.venues.values.first?.id ?? "unknown"
            
            Task {
                await MainActor.run {
                    GameClient.gameClient.venue = self.venue
                }
            }
        }
        
        print("starting quests:", Quest.addedQuests.count)
    }
    
    enum CodingKeys: CodingKey {
        case venueID, playerID
        case currentOperation, cancelOperationAfterPerform, operationResults
        case initialTick, tickScheduler
        case gameClock
    }
    
    func oneTimeSetup() {
//        self.venue!.name = Game.venues.values.first?.name ?? "unknown"
        self.venue!.playerCharacterID = "cire"
        
//        self.venue!.setupDroppedItems()
//        self.server!.update(droppedItems: self.venue!.droppedItems)
        
        self.changed = true
    }
    
    func getVenueData() -> Venue {
        self.venue!
    }
    
    func getCharacters() -> Character.Characters {
        guard Self.characters.data.isEmpty else { return Self.characters}
        
//        for character in [
//            Character.create(given: "Cire", gender: .male, type: .player, locality: Locality(position: VenuePosition(hex: (0,1), x: 50, y:0), type: .authoritative)
//                                  , facing: 1),
//            //            KnownCharacter(id: "bob", type: .character, given: "Bob", gender: .male, venue: Game.venues.values.first?.id ?? "unknown", locality: Locality(position: VenuePosition(hex: (2,2), x: 0, y: 0), type: .authoritative), facing: 3)!,
//        ] {
//            Self.characters.accept(character: character)
//            if character.type == .player {
//                self.playerID = character.id
//                self.player?.mountingPoints.characterID = character.id
//            }
//        }
        
        return Self.characters
    }
}
