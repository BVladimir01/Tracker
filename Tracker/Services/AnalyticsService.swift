//
//  AppMetricaService.swift
//  Tracker
//
//  Created by Vladimir on 21.06.2025.
//

import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "") else {
            assertionFailure("AnalyticsService.activate: failed to get configuration")
            return
        }
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: AnalyticsEvent, screen: String = "Main", item: AnalyticsUIItem?) {
        var parameters: [AnyHashable: Any] = [:]
        parameters["event"] = event.rawValue
        parameters["screen"] = screen
        if let item {
            parameters["item"] = item.rawValue
        }
        AppMetrica.reportEvent(name: event.rawValue, parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}


enum AnalyticsEvent: String {
    case open, close, click
}

enum AnalyticsUIItem: String {
    case addTrack, track, filter, edit, delete
}
