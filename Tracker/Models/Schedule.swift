//
//  Schedule.swift
//  Tracker
//
//  Created by Vladimir on 05.05.2025.
//


import Foundation

enum Schedule: Codable {
    case regular(Set<Weekday>)
    case irregular(Date)
}


final class ScheduleBoxedValue: BoxedValue<Schedule> { }
