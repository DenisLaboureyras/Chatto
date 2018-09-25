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

open class SectionHeaderViewModel: SectionHeaderViewModelProtocol {
   
    open lazy var date: String = {
        return self.dateFormatter.string(from: self.sectionHeaderModel.date)
    }()
    
    public let dateFormatter: DateFormatter
    open fileprivate(set) var sectionHeaderModel: SectionHeaderModelProtocol
    
    public let text: String
    
    public init(dateFormatter: DateFormatter, sectionHeaderModel: SectionHeaderModelProtocol) {
        self.text = sectionHeaderModel.text;
        self.dateFormatter = dateFormatter
        self.sectionHeaderModel = sectionHeaderModel;
    }
   
}



open class SectionHeaderViewModelDefaultBuilder: SectionHeaderViewModelBuilderProtocol {
    public typealias ModelT = SectionHeaderModel
    public typealias ViewModelT = SectionHeaderViewModel
    
    public init() {
        
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "DD-MM-YYYY"
        return formatter
    }()
    
    open func createSectionHeaderViewModel(_ sectionHeader: SectionHeaderModel) -> SectionHeaderViewModel
    {
        return SectionHeaderViewModel(dateFormatter: type(of: self).dateFormatter, sectionHeaderModel: sectionHeader)
    }
}
