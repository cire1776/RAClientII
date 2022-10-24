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

class Game: TickHolder, BeatNotifier {
    static var game: Game!
//    static var environment: Game.Environment!
    static var venues: [Venue.ID : Venue] = [:]
    
    static var startingVenues: [()] = [
        add(venue: Venue(named: "Primera", description: "The first place"))
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
    
    var heartbeat: Heartbeat!
    
    let initialTick: UInt64
    
    var currentTick: UInt64 { self.tick }
    
//    var tickScheduler = [UInt64 : [String: Schedulable]]()
    
    var playerID: Character.ID
    
    var player: Character? {
        Self.characters.data[playerID]
    }
    
//    var operationResults: Operation.Result! = nil
    
    var changed = false
    
    var savingEvent: (String, UInt) = ("",0)
    
    override init() async {
        self.initialTick = 2_500
        
        self.playerID = "cire"
        
        restoreItemTypes()
        
        await super.init()
        
        triggerLazy(loadEverything: true)
    }
    
    public subscript(source: ModelType, index: String) -> AnyObject? {
        switch source {
        case .venue:
            return Game.venues[index]
        case .item:
            return Game.items[index]
        case .itemType:
            return Game.itemTypes[index]
        default:
            return ModelType.Unknown()
        }
    }
    
    func beat() async {
        await advanceTick()
    }
    
    private func triggerLazy(loadEverything: Bool = false) {
//        Endorsement.setupRegisteredEndorsements()
//        Game.environment = Game.Environment()
        
        // lazy evaluations,
        
        if loadEverything {
            print("starting venues:", Game.startingVenues.count)
//            _ = Facilities.setupOperations
            
            self.venueID = Game.venues.values.first?.id ?? "unknown"
        }
        
        print("starting quests:", Quest.addedQuests.count)
    }
    
    enum CodingKeys: CodingKey {
        case venueID, playerID
        case currentOperation, cancelOperationAfterPerform, operationResults
        case initialTick, tickScheduler
        case gameClock
    }
    
    required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Game.CodingKeys> = try decoder.container(keyedBy: Game.CodingKeys.self)
        
        self.venueID = try container.decode(Venue.ID.self, forKey: Game.CodingKeys.venueID)
        self.playerID = try container.decode(Character.ID.self, forKey: Game.CodingKeys.playerID)
//        self.currentOperation = try container.decodeIfPresent(Game.Operation.self, forKey: Game.CodingKeys.currentOperation)
//        self.cancelOperationAfterPerform = try container.decode(Bool.self, forKey: Game.CodingKeys.cancelOperationAfterPerform)
//        self.operationResults = try container.decodeIfPresent(Game.Operation.Result.self, forKey: Game.CodingKeys.operationResults)
        self.initialTick = try container.decode(UInt64.self, forKey: Game.CodingKeys.initialTick)
        
//        do {
//            self.gameClock = try container.decode(GameClock.self, forKey: .gameClock)
//            self.gameClock.game = self
//            self.gameClock.start()
//        } catch {
//            print("**** Failed to get game clock")
//            self.gameClock = GameClock(game: self, initialTick: self.initialTick)
//        }
        
//        let newSchedule = try container.decode([UInt : [String : Schedulable.Kind]].self, forKey: Game.CodingKeys.tickScheduler)
        
//        for (tick, events) in newSchedule {
//            self.tickScheduler[tick] = [:]
//            for (label, schedulableKind) in events {
//                switch schedulableKind {
//                case .cancelEndorsement(let schedulable):
//                    self.tickScheduler[tick]![label] = schedulable
//                case .cancelEndorsementWithFutureEndorsement(let schedulable):
//                    self.tickScheduler[tick]![label] = schedulable
//                case .waypointArrival(let schedulable):
//                    self.tickScheduler[tick]![label] = schedulable
//                case .perform(let schedulable):
//                    self.tickScheduler[tick]![label] = schedulable
//                case .anticipate(let schedulable):
//                    self.tickScheduler[tick]![label] = schedulable
//                case .savingEvent:
//                    break
//                }
//            }
//        }
        try super.init(from: decoder)
        
        triggerLazy()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<Game.CodingKeys> = encoder.container(keyedBy: Game.CodingKeys.self)
        
        try container.encode(self.venueID, forKey: Game.CodingKeys.venueID)
        try container.encode(self.playerID, forKey: Game.CodingKeys.playerID)
//        try container.encodeIfPresent(self.currentOperation, forKey: Game.CodingKeys.currentOperation)
//        try container.encode(self.cancelOperationAfterPerform, forKey: Game.CodingKeys.cancelOperationAfterPerform)
//        try container.encodeIfPresent(self.operationResults, forKey: Game.CodingKeys.operationResults)
        try container.encode(self.initialTick, forKey: Game.CodingKeys.initialTick)
//        try container.encode(self.gameClock, forKey: .gameClock)
        
//        var newSchedule = [UInt : [String : Schedulable.Kind]]()
        
//        for (tick, events) in self.tickScheduler {
//            newSchedule[tick] = [:]
//            for (label, schedulable) in events {
//                guard schedulable.savable else { continue }
//                newSchedule[tick]![label] = schedulable.kind
//            }
//        }
        
//        try container.encode(newSchedule, forKey: Game.CodingKeys.tickScheduler)
    }
    
    
    func oneTimeSetup() {
        self.venue!.name = Game.venues.values.first?.name ?? "unknown"
        self.venue!.playerCharacter = "cire"
        
        self.venue!.setupDroppedItems()
//        self.server!.update(droppedItems: self.venue!.droppedItems)
        
        self.changed = true
    }
    
    func tick(_ tick: UInt64) {
//        guard let actions = tickScheduler.removeValue(forKey: tick) else { return }
//        
//        for action in actions.values {
//            action.execute(at: tick)
//        }
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
