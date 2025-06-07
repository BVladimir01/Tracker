//
//  Weekday.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

import Foundation

enum Weekday: Int, CaseIterable, Equatable, Comparable, Codable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    
    static func fromCalendarComponent(_ index: Int) -> Weekday? {
        let gregorianOrdered: [Weekday?] = [nil, .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        // safe return
        if gregorianOrdered.indices.contains(index) {
            return gregorianOrdered[index]
        } else {
            return nil
        }
    }
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
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
