//
//  BaseChatViewControllerView.swift
//  Pods
//
//  Created by Denis Laboureyras on 27/05/2016.
//
//

import Foundation

// http://stackoverflow.com/questions/24596031/uiviewcontroller-with-inputaccessoryview-is-not-deallocated
final class BaseChatViewControllerView: UIView {
    
    var bmaInputAccessoryView: UIView?
    
    override var inputAccessoryView: UIView? {
        return self.bmaInputAccessoryView
    }
}