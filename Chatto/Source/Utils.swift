//
//  Utils.swift
//  Pods
//
//  Created by Denis Laboureyras on 05/10/2016.
//
//

import Foundation


private let scale = UIScreen.main.scale

infix operator >=~
func >=~ (lhs: CGFloat, rhs: CGFloat) -> Bool {
    return round(lhs * scale) >= round(rhs * scale)
}
