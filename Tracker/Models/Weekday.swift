//
//  Weekday.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

import Foundation

enum Weekday: Int, CaseIterable, Equatable, Comparable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        if lhs == sunday {
            return false
        }
        if rhs == sunday {
            return true
        }
        return lhs.rawValue < rhs.rawValue
    }
    
    func asString(short: Bool) -> String {
        switch self {
        case .sunday:
            short ? "Вс" : "Воскресенье"
        case .monday:
            short ? "Пн" : "Понедельник"
        case .tuesday:
            short ? "Вт" : "Вторник"
        case .wednesday:
            short ? "Ср" : "Среда"
        case .thursday:
            short ? "Чт" : "Четверг"
        case .friday:
            short ? "Пт" : "Пятница"
        case .saturday:
            short ? "Сб" : "Суббота"
        }
    }
    
}
