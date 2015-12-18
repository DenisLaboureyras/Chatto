//
//  SectionHeaderCollectionViewCellDefaultStyle.swift
//  Pods
//
//  Created by Denis Laboureyras on 18/12/2015.
//
//

import Foundation

public class SectionHeaderCollectionViewCellDefaultSyle: SectionHeaderCollectionViewCellStyleProtocol {
    
    public init () {}
    
    private lazy var dateFont = {
        return UIFont.systemFontOfSize(12.0)
    }()
    
    public func attributedStringForDate(date: String) -> NSAttributedString {
        let attributes = [NSFontAttributeName : self.dateFont]
        return NSAttributedString(string: date, attributes: attributes)
    }
    
}
