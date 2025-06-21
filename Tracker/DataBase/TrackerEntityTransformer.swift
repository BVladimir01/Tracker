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
              let colorEntity = trackerEntity.color,
              let emoji = trackerEntity.emoji,
              let categoryEntity = trackerEntity.category,
              let categoryTitle = categoryEntity.title,
              let categoryID = categoryEntity.id
        else {
            throw TrackerDataStoresError.trackerPropertiesNotInitialized(forObjectID: trackerEntity.objectID)
        }
        let rgbColor = RGBColor(red: colorEntity.red,
                              green: colorEntity.green,
                              blue: colorEntity.blue,
                              alpha: colorEntity.alpha)
        let schedule = try schedule(of: trackerEntity)
        let category = TrackerCategory(id: categoryID, title: categoryTitle)
        return Tracker(id: id,
                       title: title,
                       color: rgbColor,
                       emoji: Character(emoji),
                       schedule: schedule,
                       category: category,
                       isPinned: trackerEntity.isPinned)
    }
    
    private func schedule(of trackerEntity: TrackerEntity) throws -> Schedule {
        if trackerEntity.isRegular {
            var weekdaysMask = trackerEntity.weekdaysMask
            var weekdays = Set<Weekday>()
            var weekdayRawValue = 0
            while weekdaysMask != 0 {
                guard let newWeekday = Weekday(rawValue: weekdayRawValue) else {
                    throw TrackerDataStoresError.unexpected(message: "TrackerStore.schedule: Failed to create weekday from raw value")
                }
                if weekdaysMask & 1 != 0 {
                    weekdays.insert(newWeekday)
                }
                weekdayRawValue += 1
                weekdaysMask >>= 1
            }
            if weekdays.isEmpty {
                throw TrackerDataStoresError.unexpected(message: "Tracker.schedule: Weekdays are empty")
            }
            return .regular(weekdays)
        } else {
            guard let date = trackerEntity.date else {
                throw TrackerDataStoresError.trackerPropertiesNotInitialized(forObjectID: trackerEntity.objectID)
            }
            return .irregular(date)
        }
    }
    
}
