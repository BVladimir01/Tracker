//
//  Weekday.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//

import Foundation


// MARK: - Weekday
enum Weekday: Int, CaseIterable, Equatable, Comparable, Codable {
    
    // MARK: - Cases
    
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    
    // MARK: - Internal Methods
    
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
        let gregorianIndex = (rawValue + 1) % 7
        return short ? Calendar.current.shortWeekdaySymbols[gregorianIndex] : Calendar.current.weekdaySymbols[gregorianIndex]
    }
    
}
