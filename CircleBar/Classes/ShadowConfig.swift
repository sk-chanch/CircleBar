//
//  ShadowConfig.swift
//  CircleBar
//
//  Created by Chanchana Koedtho on 6/1/2565 BE.
//

import Foundation
import UIKit

public struct ShadowConfig{
  
    
    var shadowColor:CGColor
    var shadowOpacity:Float
    var shadowRadius:CGFloat
    var shadowOffset:CGSize
    
    public init(shadowColor: UIColor,
                shadowOpacity: Float,
                shadowRadius: CGFloat,
                shadowOffset: CGSize) {
        self.shadowColor = shadowColor.cgColor
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }
    
    public init(_ shadowColor:UIColor){
        let ds = ShadowConfig.defaultShadow()
        self.shadowColor = shadowColor.cgColor
        self.shadowOpacity = ds.shadowOpacity
        self.shadowRadius = ds.shadowRadius
        self.shadowOffset = ds.shadowOffset
    }
    
    public static func defaultShadow()->ShadowConfig{
        .init(shadowColor: UIColor.lightGray,
              shadowOpacity:  0.7,
              shadowRadius: 3,
              shadowOffset: .init(width: 1, height: 2))
    }
}
