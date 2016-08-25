//
//  SectionHeaderModel.swift
//  Pods
//
//  Created by Denis Laboureyras on 18/12/2015.
//
//

import Foundation
import Chatto


public protocol SectionHeaderModelProtocol: ChatItemProtocol {
    var text: String { get }
    var date: Date { get }
}

public protocol DecoratedSectionHeaderModelProtocol: SectionHeaderModelProtocol {
    var sectionHeaderModel: SectionHeaderModelProtocol { get }
}

public extension DecoratedSectionHeaderModelProtocol {
    var uid: String {
        return self.sectionHeaderModel.uid
    }
    
    var date: Date {
        return self.sectionHeaderModel.date
    }
}

open class SectionHeaderModel: SectionHeaderModelProtocol {
    open var uid: String
    open var type: String
    open var date: Date
    open var text: String
    
    public init(uid: String, type: String, text: String, date: Date) {
        self.text = text;
        self.uid = uid
        self.type = type
        self.date = date
    }
}
