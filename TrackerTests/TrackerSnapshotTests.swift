//
//  TrackerSnapshotTests.swift
//  TrackerSnapshotTests
//
//  Created by Vladimir on 21.06.2025.
//

import SnapshotTesting
@testable import Tracker
import XCTest

final class TrackerSnapshotTests: XCTestCase {

    func testTrackersListVC() {
        let trackerStoreMock = TrackerStoreMock()
        let recordStoreStub = RecordStoreStub()
        let categoryStoreStub = CategoryStoreStub()
        let vc = TrackersListViewController(trackerStore: trackerStoreMock,
                                            categoryStore: categoryStoreStub,
                                            recordStore: recordStoreStub)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), record: false)
        assertSnapshot(of: vc, as: .recursiveDescription(traits: .init(userInterfaceStyle: .light)), record: false)
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), record: false)
        assertSnapshot(of: vc, as: .recursiveDescription(traits: .init(userInterfaceStyle: .dark)), record: false)
    }

}
