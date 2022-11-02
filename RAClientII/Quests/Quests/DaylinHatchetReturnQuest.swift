//
//  DaylinHatchetReturnQuest.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/10/22.
//

import Foundation

extension Quest {
    static let DaylinHatchetReturnQuest = { (quest: Quest) -> [String : Interchange] in
        Exchange.add(for: "daylin", exchange: .quest(
            label: "Return Hatchets to Daylin",
            questID: "Daylin Hatchet Return Quest",
            enablers: [
                .endorsement("daylin sharpening quest"),
                .hasInInventory("hatchet", quantity: 1),
                .greaterThanOrEqualTo("daylin sharpening quest", value: 1)
            ]
        ))
        
        var numberOfHatchets: UInt
        
        return [
            "A" : Dialogue(in: quest, line: "Good Job! A fine, well-sharpened hatchet.",responses: [
                "::" : .sequence([
                    .receive("hatchet", quantity: 1),
//                    .decrement(endorsement: "daylin sharpening quest"),
                    .hasItem("hatchet", quantity: 1,
                             if: .message("Thank you! Another well-sharpened hatchet."),
                             else: .goto(interaction: "B", index: 0)),
                ])
            ]) { text in
                guard text == "::" else { return text }
                let hasItem = GameClient.gameClient.player.has(itemOfType: "hatchet", quantity: 1)
                return hasItem ? "Return another hatchet." : ""
            },
            "B" : Monologue(in: quest, lines: [
//                .hasEndorsement("daylin sharpening quest",
//                    if: .message("I can't wait to see what you do with the rest of the dull hatchets."),
//                    else: .message("Great Job!  I should have more dull hatchets soon.")
//                ),
                .end
            ])
        ]
    }
}
