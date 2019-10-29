//
//  DefaultTransformer.swift
//  hom
//
//  Created by Dean Foster on 10/27/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation

@objc(DefaultTransformer)
class DefaultTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override open func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Data else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: value)
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value else {
            return nil
        }
        return NSKeyedArchiver.archivedData(withRootObject: value)
    }
}
