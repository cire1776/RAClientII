//
//  Characters.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/13/22.
//

import Foundation

extension Character {
    class Characters: ObservableObject {
        var data = [String : Character]()
        
        func accept(character: Character) {
            data[character.id] = character
        }
        
        subscript(index: String) -> Character? {
            get {
                data[index]
            }
            
            set {
                data[index] = newValue
            }
        }
    }
}
