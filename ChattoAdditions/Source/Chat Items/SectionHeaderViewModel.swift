//
//  SectionHeaderViewModel.swift
//  Pods
//
//  Created by Denis Laboureyras on 18/12/2015.
//
//

import Foundation
import Chatto

public protocol SectionHeaderViewModelProtocol: class { // why class? https://gist.github.com/diegosanchezr/29979d22c995b4180830
    var text: String { get }
    var date: String { get }
    var sectionHeaderModel: SectionHeaderModelProtocol { get }
}

public protocol DecoratedSectionHeaderViewModelProtocol: SectionHeaderViewModelProtocol {
    var sectionHeaderViewModel: SectionHeaderViewModelProtocol { get }
}

extension DecoratedSectionHeaderViewModelProtocol {
    public var date: String {
        return self.sectionHeaderViewModel.date
    }

    public var sectionHeaderModel: SectionHeaderModelProtocol {
        return self.sectionHeaderViewModel.sectionHeaderModel
    }
}

public class SectionHeaderViewModel: SectionHeaderViewModelProtocol {
   
    public lazy var date: String = {
        return self.dateFormatter.stringFromDate(self.sectionHeaderModel.date)
    }()
    
    public let dateFormatter: NSDateFormatter
    public private(set) var sectionHeaderModel: SectionHeaderModelProtocol
    
    public let text: String
    
    public init(dateFormatter: NSDateFormatter, sectionHeaderModel: SectionHeaderModelProtocol) {
        self.text = sectionHeaderModel.text;
        self.dateFormatter = dateFormatter
        self.sectionHeaderModel = sectionHeaderModel;
    }
   
}



public class SectionHeaderViewModelDefaultBuilder: SectionHeaderViewModelBuilderProtocol {
    public typealias ModelT = SectionHeaderModel
    public typealias ViewModelT = SectionHeaderViewModel
    
    public init() {
        
    }
    
    static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "DD-MM-YYYY"
        return formatter
    }()
    
    public func createSectionHeaderViewModel(sectionHeader: SectionHeaderModel) -> SectionHeaderViewModel
    {
        return SectionHeaderViewModel(dateFormatter: self.dynamicType.dateFormatter, sectionHeaderModel: sectionHeader)
    }
}