//
//  GameClient.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/6/22.
//

import Foundation
import Combine

typealias OperationTimesList = [String : UInt]

public enum ActionReliability: Codable {
    case none, predictive, authoritative
}

// Predictive Object
class GameClient: ObservableObject, ActionRegisterable, BeatNotifier {
    //, TimeDescribing {

    static var gameScene: GameScene!
    static var gameClient: GameClient!

    // Authoritative Source for these Properties
    @Published var player: Character!
    @Published var characters: Character.Characters!
    @Published var venue: Venue!
//    @Published var operation: Operation?
    
    var operationTimes : OperationTimesList = [:]
    
    @Published var tick: UInt64 = 0
    
    var heartbeat: Heartbeat!

    var actionRegistry = [Action.ID : (UInt64?, TickAction)]()

//    var tickScheduler = [UInt : [TickAction]]()
//
//    var tickActions = [String: TickAction]()
//    var secondsActions = [String : TickAction]()
    
    private var holdTicks: UInt = 0
    private var firstTick = true
    
    @Published var ready = false // PassthroughSubject<Bool, Never>()
    private var readyMask: UInt8 = 0xF8 {
        didSet {
            if self.readyMask == 0xFF {
                DispatchQueue.main.async {
                    self.ready = true
                    // mark that ready has been signaled.
                    self.readyMask = 0x7F
                }
            }
        }
    }
    
    init() {
//        self.venue = Venue()
//        self.characters = Character.Characters()
        heartbeat = Heartbeat(beatNotifier: self)
    }
    
    func start() {
        let subscriber = self.$ready
                                   .receive(on: DispatchQueue.main)
                                   .sink { ready in
            if ready {
                print("game ready.")
                GameClient.gameScene.initialize()
//                self.venue.recordAllCharacters()
            }
        }
        
        allSubscriptions.insert(subscriber)
    }
    
    func beat() async {
        print(".", separator: "")
    }
//    func update(venue: Venue) {
//        DispatchQueue.main.async {
//            self.readyMask |= 0x01
//        }
//    }
    
//    func updateCharacters(with characters: Character.Characters) {
//        DispatchQueue.main.async {
//            self.characters = characters
//            self.readyMask |= 0x02
//        }
//    }
//
//    func updatePlayer(with player: Character) {
//        DispatchQueue.main.async {
//            self.player = player
//            if let characters = self.characters {
//                characters.accept(character: player)
//            }
//            self.readyMask |= 0x04
//        }
//    }
//
//    func update(droppedItems: [String: DroppedItem]) {
//        DispatchQueue.main.async {
//            self.venue.droppedItems = droppedItems
//        }
//
//    }
//
//    func update(droppedItem: DroppedItem) {
//        DispatchQueue.main.async {
//            self.venue.droppedItems[droppedItem.id] = droppedItem
//        }
//    }
//
//    func remove(droppedItemID: String) {
//        DispatchQueue.main.async {
//            if let item = self.venue.droppedItems.removeValue(forKey: droppedItemID) {
//                self.venue.interactablesMap.remove(item)
//                self.venue.droppedItemsMap.remove(item)
//            }
//        }
//    }
//
//    func update(_ character: Character) {
//        Task {
//            await MainActor.run {
//                venue.add(character)
//            }
//        }
//    }
//
//    func remove(_ character: Character.ID) {
//        Task {
//            await MainActor.run {
//                venue.remove(character)
//            }
//        }
//    }
//
//    func addToPlayerInventory(with inventoryChanges: Set<Item>) {
//        Task {
//            while readyMask & 0x04 == 0 {
//                print("waiting for readyMask: \(readyMask) on: \(Thread.isMainThread)" )
//
//                try! await Task.sleep(nanoseconds: 10_000)
//            }
//
//            try! await Task.sleep(nanoseconds: 10_000)
//
//            await MainActor.run {
//                for item in inventoryChanges {
//                    self.player.add(item: item, authority: .authoritative)
//                }
//            }
//        }
//    }
//
//    func useSubordinateInventory(id: String, massCapacity: UInt, contentFilterID: String?) {
//        self.player.subordinate = SubordinateInventory(id: nil, massCapacity: massCapacity, contentFilterID: contentFilterID)
//    }
//
//    func endSubordinateInventory() {
//        self.player.subordinate = nil
//    }
//
//    func updateSubordinateInventory(newBalance: Set<Item>) {
//        for item in newBalance {
//            print("$$$$: \(item.type.description) (\(item.quantity))")
//        }
//    }
//
//    func updateOperationResult(with results: Operation.Result) {
//        guard let operation = self.operation else { return }
//        print("**** in client processing operation results")
//        operation.nextResult = results
//
//        if operation.waitingForResults {
//            operation.perform()
//        }
//    }
//
//    func updateItemTypes(with newItems: [String: ItemType], partial: Bool) {
//        if partial {
//            ItemType.itemTypes.merge(newItems) { $1 }
//        } else {
//            ItemType.itemTypes = newItems
//        }
//    }
//
//    func updateLocality(_ locality: Locality, for characterID: Character.ID, movementReady: Bool = false) {
//        guard let character = characters[characterID] else { return }
//        character.locality = locality
//    }
//
//    func update(facility: Facility) {
//        GameClient.gameScene.hexagonMapNode.updateFacilityNode(for: facility)
//    }
//
//    func updateOperationTimes(with operationTimes: OperationTimesList) {
//        self.operationTimes.merge(operationTimes) { $1 }
//    }
//
//    func beginOperation(named name: String) {
//        Self.ServerProxy.beginOperation(operationName: name, context: self.operation!.context)
//    }
//
//    func authoritate() {
//        self.operation?.authority = .authoritative
//    }
//
//    func buildFacility(id: Facility.ID, kind: Facility.Kind, specifier: String, position: VenuePosition) {
//        _ = self.venue.addFacility(id: id, kind: kind, specifier: specifier, position: position)
//    }
//
//    func demolishFacility(facilityID: Facility.ID) {
//        self.venue.facilities.removeValue(forKey: facilityID)
//
//        var facilityNodes = GameClient.gameScene.hexagonMapNode.facilityNodes
//
//        if let node = facilityNodes[facilityID] {
//            if let facility = venue.facilities.removeValue(forKey: facilityID) {
//                venue.facilitiesMap.remove(facility)
//            }
//            facilityNodes.removeValue(forKey: facilityID)
//            node.removeFromParent()
//        }
//    }
//
//    func endOperation(forced: Bool = false) {
//        if !forced {
//            Self.ServerProxy.endOperation()
//        }
//
//        DispatchQueue.main.async {
//            self.operation = nil
//        }
//    }
//
//    func updateTick(with newTick: UInt) {
//        guard newTick != self.tick else { return }
//
//        Task {
//            await MainActor.run {
//                if self.firstTick {
//                    self.tick = newTick
//                    self.firstTick = false
//
//                    return
//                }
//
//                if newTick > self.tick {
//                    for _ in 0..<(newTick - self.tick) {
//                        self.issueTick()
//                    }
//                } else {
//                    self.holdTicks = self.tick - newTick
//                }
//            }
//        }
//    }
//
//    func cancelOperation() {
//        let gameScene = GameClient.gameScene!
//        let localCharacter = self.player!
//
//        gameScene.uiDelegate.selectedFacility = nil
//        localCharacter.occupied = false
//        gameScene.characters[localCharacter.id]?.occupied = false
//
//        gameScene.gameClient.operation?.end()
//    }
//

    
    func add(buff: BuffSpecifier) {
    }
    
    func removeBuff(label: BuffSpecifier.ID)  {
    }
}
