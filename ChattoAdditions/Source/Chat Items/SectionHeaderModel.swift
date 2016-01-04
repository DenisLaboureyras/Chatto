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
    var date: NSDate { get }
}

public protocol DecoratedSectionHeaderModelProtocol: SectionHeaderModelProtocol {
    var sectionHeaderModel: SectionHeaderModelProtocol { get }
}

public extension DecoratedSectionHeaderModelProtocol {
    var uid: String {
        return self.sectionHeaderModel.uid
    }
    
    var date: NSDate {
        return self.sectionHeaderModel.date
    }
}

public class SectionHeaderModel: SectionHeaderModelProtocol {
    public var uid: String
    public var type: String
    public var date: NSDate
    public var text: String
    
    public init(uid: String, type: String, text: String, date: NSDate) {
        self.text = text;
        self.uid = uid
        self.type = type
        self.date = date
    }
}
