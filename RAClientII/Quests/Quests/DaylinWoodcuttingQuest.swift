//
//  DaylinWoodcuttingQuest.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/3/22.
//

import Foundation

extension Quest {
    static let DaylinWoodCuttingQuest = { (quest: Quest) -> [String : Interchange] in
        Exchange.add(for: "daylin", exchange: .quest(
            label: "Approach Man Working with Axes",
            questID: "Daylin Woodcutting Quest",
            enablers: [.notEndorsement("woodcutting")]
        ))
        
        return [
            "A" : Dialogue(in: quest, line: "Daylin is busy working with some hatchets and axes.\n\nIntrigued, you respond:", responses: [
                "\"What are you doing?\"" : .goto(interaction: "B",index: 0),
                "Stand there watching him." : .goto( interaction: "D", index: 0),
//                "Walk away" : .sequence([.increment(endorsement: "Daylin Woodcutting Quest: Lurking"), .end])
            ]),
            "B" : Dialogue(in: quest, line: "\"A woodcutter is only as good as his tools.  If (he/she) takes care of them, they'll take care of (him/her).  These are in need of some serious sharpening.\"", responses: [
                    "\"Oh, doesn't look too hard.  Can I try it?\"" : .goto(interaction:"C", index:  0),
//                    "Walk away" : .sequence([.increment(endorsement: "Daylin Woodcutting Quest: Lurking"), .end]),
            ]),
            "C" : Monologue(in: quest, lines: [
                .message("\"Why don't we see what kind of a woodcutter you'd be.\"  He picks up a second whetstone and hands it to you."),
                .give("whetstone", quantity: 1),
//                .skill(skill: .woodcutting, skillLevel: .novice, rank: 1),
                .message("\"Do well and you can keep that.\"  He explains the process to you, demoing the process a couple of times and then hands you an old beat up hatchet.  \"Try sharpening this one first.\""),
                .give("hatchet, dull", quantity: 1),
                .message("Daylin returns to his own sharpening."),
                .end,
            ]),
            "D" : Dialogue(in: quest, line: "You notice that he is holding the blade at a consistent angle to the stone.", responses: [
                "What are you doing?" : .sequence([
//                    .endorse(endorsement: "keen sharpening eye", buff: .skill(skill: .woodcutting, strength: 1)),
                    .goto(interaction: "B", index: 0)
                ]),
//                "Walk away" : .sequence([.increment(endorsement: "Daylin Woodcutting Quest: Lurking"), .end]),
            ]),
            "E" : SwitchDialogue(in: quest, .greaterThan(value: 2, key: "Daylin Woodcutting Quest: Lurking", true: .goto(interaction:"F", index:0), false: .goto(interaction:"G", index:0))),
        ]
    }
}
