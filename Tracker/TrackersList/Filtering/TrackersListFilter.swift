//
//  Filter.swift
//  Tracker
//
//  Created by Vladimir on 15.06.2025.
//

import Foundation


enum TrackersListFilter: String, CaseIterable {
    case all, today, completed, uncompleted
    var asString: String {
        switch self {
        case .all:
            Strings.all
        case .today:
            Strings.today
        case .completed:
            Strings.completed
        case .uncompleted:
            Strings.uncompleted
        }
    }
}


// MARK: - Strings
extension TrackersListFilter {
    enum Strings {
        static let all = NSLocalizedString("trackerFilter.all", comment: "")
        static let today = NSLocalizedString("trackerFilter.today", comment: "")
        static let completed = NSLocalizedString("trackerFilter.completed", comment: "")
        static let uncompleted = NSLocalizedString("trackerFilter.uncompleted", comment: "")
    }
}
