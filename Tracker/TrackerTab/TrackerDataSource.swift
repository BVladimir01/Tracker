//
//  TrackerDataSource.swift
//  Tracker
//
//  Created by Vladimir on 08.05.2025.
//

import Foundation


protocol TrackerDataSource {
    var trackerCategories: [TrackerCategory] { get }
}
