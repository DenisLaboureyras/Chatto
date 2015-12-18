//
//  SectionItemProtocolDefinitions.swift
//  Chatto
//
//  Created by Denis Laboureyras on 17/12/2015.
//  Copyright © 2015 Badoo. All rights reserved.
//

import Foundation

public typealias SectionItemType = String

public protocol SectionItemProtocol: class, UniqueIdentificable {
    var section : ChatItemProtocol { get }
    var items : [ChatItemProtocol] { get }
}

public class SectionItem: SectionItemProtocol {

    public var section : ChatItemProtocol
    public var items : [ChatItemProtocol]
    
    public var uid: String
    
    public init(section: ChatItemProtocol, items: [ChatItemProtocol]){
        self.section = section;
        self.items = items;
        self.uid = section.uid;
    }
}