//
//  Index.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/3/22.
//

import Foundation

extension Quest {
    // Used simply to trigger creation at static initialization time
    static var addedQuests : [Quest] = [
        Quest("Daylin Woodcutting Quest", DaylinWoodCuttingQuest),
        Quest("Daylin Sharpening Quest", DaylinSharpeningQuest),
        Quest("Daylin Hatchet Return Quest", DaylinHatchetReturnQuest),
    ]
}
