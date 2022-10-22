//
//  NonPlayerCharacter.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/3/22.
//

import Foundation

protocol EnableCheckable: /*Endorsable, */ItemHolding {}

enum Enabler: Codable {
    static func isEnabled(_ enablers: [Enabler], given checkable: any EnableCheckable) -> Bool {
        enablers.allSatisfy({ $0.isEnabled(given: checkable) })
    }
    
    case endorsement(String), notEndorsement(String)
    case skillLevel(Skill, UInt), notSkillLevel(Skill, UInt)
    case hasInInventory(ItemType.ID, quantity: UInt), doesNotHaveInInventory(ItemType.ID, quantity: UInt)
    
    case equalTo(_ key: Endorsement.Key, value: UInt)
    case notEqualTo(_ key: Endorsement.Key, value: UInt)
    case lessThan(_ key: Endorsement.Key, value: UInt)
    case greaterThan(_ key: Endorsement.Key, value: UInt)
    case lessThanOrEqualTo(_ key: Endorsement.Key, value: UInt)
    case greaterThanOrEqualTo(_ key: Endorsement.Key, value: UInt)
    
    func isEnabled(given checkable: any EnableCheckable) -> Bool {
        switch self {
        case .endorsement(_):
            break
//            return checkable.endorsements[endorsement] != nil
        case .notEndorsement(_): break
//            return checkable.endorsements[endorsement] == nil
        case .skillLevel(_, _): break
//            switch checkable.endorsements[skill.rawValue] {
//            case .none:
//                return false
//            case .some(.skill(skillLevel: let skillLevel, rank: _, xp: _)):
//                return (SkillLevel.level[skillLevel] ?? 0) >= level
//            default:
//                return false
//            }
//        case .notSkillLevel(let skill, let level):
//            switch checkable.endorsements[skill.rawValue] {
//            case .none:
//                return true
//            case .some(.skill(skillLevel: let skillLevel, rank: _, xp: _)):
//                return (SkillLevel.level[skillLevel] ?? 0) < level
//            default:
//                return false
//            }
        case .hasInInventory(let itemTypeID, quantity: let quantity):
            return checkable.has(itemOfType: itemTypeID, quantity: quantity)
        case .doesNotHaveInInventory(let itemTypeID, quantity: let quantity):
            return !checkable.has(itemOfType: itemTypeID, quantity: quantity)
        case .equalTo(_, _): break
//            print("Evaluating .count")
//            switch checkable.endorsements[key] {
//            case .tallied(_, count: let count),
//                 .key(value: let count),
//                 .timeout(_, count: let count, _, _):
//                return count == value
//            default:
//                print("endorsement form mismatch:",checkable.endorsements[key] as Any)
//                return false
//            }
        case .notEqualTo(_, _): break
//            print("Evaluating .count")
//            switch checkable.endorsements[key] {
//            case .tallied(_, count: let count),
//                 .key(value: let count),
//                 .timeout(_, count: let count, _, _):
//                return count != value
//            default:
//                print("endorsement form mismatch:",checkable.endorsements[key] as Any)
//                return false
//            }
        case .lessThan(_, _):
            print("Evaluating .count")
//            switch checkable.endorsements[key] {
//            case .tallied(_, count: let count),
//                 .key(value: let count),
//                 .timeout(_, count: let count, _, _):
//                return count < value
//            default:
//                print("endorsement form mismatch:",checkable.endorsements[key] as Any)
//                return false
//            }
        case .greaterThan(_, _): break
//            print("Evaluating .count")
//            switch checkable.endorsements[key] {
//            case .tallied(_, count: let count),
//                 .key(value: let count),
//                 .timeout(_, count: let count, _, _):
//                return count > value
//            default:
//                print("endorsement form mismatch:",checkable.endorsements[key] as Any)
//                return false
//            }
        case .greaterThanOrEqualTo(_, _): break
//            print("Evaluating .count")
//            switch checkable.endorsements[key] {
//            case .tallied(_, count: let count),
//                 .key(value: let count),
//                 .timeout(_, count: let count, _, _):
//                return count >= value
//            default:
//                print("endorsement form mismatch:",checkable.endorsements[key] as Any)
//                return false
//            }
        case .lessThanOrEqualTo(_, _): break
//            print("Evaluating .count")
//            switch checkable.endorsements[key] {
//            case .tallied(_, count: let count),
//                 .key(value: let count),
//                 .timeout(_, count: let count, _, _):
//                return count != value
//            default:
//                print("endorsement form mismatch:",checkable.endorsements[key] as Any)
//                return false
//            }
        case .notSkillLevel(_, _):
            return false
        }
        return false
    }
}

enum Exchange: Codable {
    static var exchanges: [Character.ID : [Exchange]] = [:]
    
    static func add(for character: Character.ID, exchange: Exchange) {
        if exchanges[character] == nil {
            exchanges[character] = []
        }
        
        exchanges[character]?.append(exchange)
    }
    
    case quest(label: String, questID: String, enablers: [Enabler])
    
    func isEnabled(given checkable: any EnableCheckable) -> Bool {
        if case let .quest(label:_, questID:_, enablers: enablers) = self {
            return Enabler.isEnabled(enablers, given: checkable)
        }
        
        return false
    }
}

protocol NonPlayerCharacter: AnyObject, Identifiable {
    var id: Character.ID  { get }
    var possibleExchanges: [Exchange] { get set }
}

extension NonPlayerCharacter {
    func setupPossibleExchanges() {
        if let possibleExchanges = Exchange.exchanges[self.id] {
            self.possibleExchanges = possibleExchanges
        }
    }
    
    func availableExchanges(given checkable: any EnableCheckable) -> [Exchange] {
        possibleExchanges.filter({
            $0.isEnabled(given: checkable)
        })
    }
}
