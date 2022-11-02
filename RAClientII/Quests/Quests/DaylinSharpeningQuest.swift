//
//  DaylinSharpeningQuest.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/7/22.
//

import Foundation

extension Quest {
    static let DaylinSharpeningQuest = { (quest: Quest) -> [String : Interchange] in
        Exchange.add(for: "daylin", exchange: .quest(
            label: "Speak with Daylin",
            questID: "Daylin Sharpening Quest",
            enablers: [
                .endorsement("woodcutting"),
                .notEndorsement("daylin sharpening quest"),
                .notSkillLevel(.woodcutting, 3)
            ]
        ))
        
        return [
            "A": Monologue(in: quest, lines: [
                .message("You approach Daylin and see that he is hard at work sharpening hatchets and axes"),
                .goto(interaction: "B", index: 0)
            ]),
            "B": Dialogue(in: quest, line: "\"Not to complain, but it seems like I have an endless number of these dull tools\"", responses: [
                                "\"Can I help?\"": .goto(interaction: "C", index: 0),
                                "\"Sorry to hear that.\"": .end,
                                "Walk away": .goto(interaction: "D", index: 0)
                          ]),
            "C": Monologue(in: quest, lines: [
                .message("\"If you'd care to, I could give you some tools that need sharpening\""),
                .goto(interaction: "C1", index: 0),
            ]),

            "C1": Dialogue(in: quest, line: "\"You would have a month to finish them.\"",responses: [
                "\"Sure!  I would love to help\"": .goto(interaction: "C2", index: 0),
                "\"Sorry.  I don't have the time for that right now\"": .goto(interaction: "C3", index: 0),
                "Walk away": .goto(interaction: "D", index: 0),
            ]),
            "C2": Monologue(in: quest, lines: [
                .message("\"Here you go!\" he says happily"),
                .give("hatchet, dull", quantity: 15),
                .message("As I mentioned before, I'll need these back within a month"),
//                .timeout(key: "daylin sharpening quest", numberOfTicks: Constants.monthTicks, count: 15, futureKey: "daylin untrusted", endorsement: .skill(buff: nil, endTick: Constants.yearTicks)),
                .end
            ]),
            "C3": Monologue(in: quest, lines: [
                .message("Daylin looks disappointed, but gets back to sharpening his tools."),
                .end
            ]),
            "D": Monologue(in: quest, lines:[.random(chance: 0.2, .message("Meh"))])
            
        ]
    }
}
