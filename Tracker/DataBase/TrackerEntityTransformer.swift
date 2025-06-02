//
//  TrackerMapper.swift
//  Tracker
//
//  Created by Vladimir on 02.06.2025.
//


struct TrackerEntityTransformer {
    func tracker(from trackerEntity: TrackerEntity) throws -> Tracker {
        guard let id = trackerEntity.id,
                let title = trackerEntity.title,
                let color = trackerEntity.rgbColor?.value,
                let emoji = trackerEntity.emoji,
              let categoryID = trackerEntity.category?.id else {
            throw TrackerStoreError.trackerPropertiesNotInitialized(forObjectID: trackerEntity.objectID)
        }
        let schedule = try schedule(of: trackerEntity)
        return Tracker(id: id,
                       title: title,
                       color: color,
                       emoji: Character(emoji),
                       schedule: schedule,
                       categoryID: categoryID)
    }
    
    private func schedule(of trackerEntity: TrackerEntity) throws -> Schedule {
        if trackerEntity.isRegular {
            var weekdaysMask = trackerEntity.weekdaysMask
            var weekdays = Set<Weekday>()
            var weekdayRawValue = 0
            while weekdaysMask != 0 {
                guard let newWeekday = Weekday(rawValue: weekdayRawValue) else {
                    throw TrackerStoreError.unexpected(message: "TrackerStore.schedule: Failed to create weekday from raw value")
                }
                weekdayRawValue >>= 1
            }
            if weekdays.isEmpty {
                throw TrackerStoreError.unexpected(message: "Tracker.schedule: Weekdays are empty")
            }
            return .regular(weekdays)
        } else {
            guard let date = trackerEntity.date else {
                throw TrackerStoreError.trackerPropertiesNotInitialized(forObjectID: trackerEntity.objectID)
            }
            return .irregular(date)
        }
    }
}
