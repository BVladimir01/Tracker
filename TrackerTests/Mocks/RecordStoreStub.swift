//
//  RecordStoreStub.swift
//  Tracker
//
//  Created by Vladimir on 15.07.2025.
//

@testable import Tracker
import UIKit


final class RecordStoreStub: RecordStoreProtocol {
    
    var delegate: (any RecordStoreDelegate)?
    
    func add(_ record: TrackerRecord) throws { }
    
    func removeRecord(from tracker: Tracker, on date: Date) throws { }
    
    func daysDone(of tracker: Tracker) throws -> Int { 0 }
    
    func isCompleted(tracker: Tracker, on date: Date) throws -> Bool { false }
    
}
