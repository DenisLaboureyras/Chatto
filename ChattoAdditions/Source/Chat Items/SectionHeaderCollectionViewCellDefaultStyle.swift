//
//  SectionHeaderCollectionViewCellDefaultStyle.swift
//  Pods
//
//  Created by Denis Laboureyras on 18/12/2015.
//
//

import Foundation

open class SectionHeaderCollectionViewCellDefaultSyle: SectionHeaderCollectionViewCellStyleProtocol {
    
    public init () {}
    
    fileprivate lazy var dateFont = {
        return UIFont.systemFont(ofSize: 12.0)
    }()
    
    open func attributedStringForDate(_ date: String) -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font : self.dateFont]
        return NSAttributedString(string: date, attributes: attributes)
    }
    
    lazy var font = {
        return UIFont.systemFont(ofSize: 13)
    }()
    
    open func textFont(viewModel: SectionHeaderViewModelProtocol) -> UIFont {
        return self.font
    }
    
    open func textColor(viewModel: SectionHeaderViewModelProtocol) -> UIColor {
        return UIColor.white
    }
    
    open func backgroundColor(viewModel: SectionHeaderViewModelProtocol) -> UIColor {
        return UIColor.darkGray
    }
    
    open func height() -> CGFloat {
        return 40
    }
    
}
