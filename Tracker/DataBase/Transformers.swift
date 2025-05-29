//
//  Transformers.swift
//  Tracker
//
//  Created by Vladimir on 29.05.2025.
//

import CoreData


class SimpleCodableValueTransformer<T: Codable>: ValueTransformer {
    
    class override func transformedValueClass() -> AnyClass { NSData.self }
    
    class override func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let codableValue = value as? T else { return nil}
        return try? JSONEncoder().encode(codableValue)
    }
    
    override func reverseTransformedValue(_ data: Any?) -> Any? {
        guard let data = data as? Data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
}


@objc(RGBColorValueTransformer)
final class RGBColorValueTransformer: SimpleCodableValueTransformer<RGBColor> {
    static func register() {
        ValueTransformer.setValueTransformer(RGBColorValueTransformer(),
                                             forName: NSValueTransformerName(String(describing: RGBColorValueTransformer.self)))
    }
}


@objc(ScheduleValueTransformer)
final class ScheduleValueTransformer: SimpleCodableValueTransformer<Schedule> {
    static func register() {
        ValueTransformer.setValueTransformer(RGBColorValueTransformer(),
                                             forName: NSValueTransformerName(String(describing: ScheduleValueTransformer.self)))
    }
}


enum TransformersRegistry {
    static func registerAll() {
        RGBColorValueTransformer.register()
        ScheduleValueTransformer.register()
    }
}
