//
//  CardInfoView.swift
//  BMSTudent
//
//  Created by Sergei Petrenko on 03/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import UIKit

class CardInfoView: UIView {

    @IBInspectable var cornerradius : CGFloat = 2
    @IBInspectable var shadowOffSetWidth : CGFloat = 0
    @IBInspectable var shadowOffSetHeight : CGFloat = 5
    @IBInspectable var shadowColor : UIColor = UIColor.black
    @IBInspectable var shadowOpacity : CGFloat = 0.5
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerradius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffSetWidth, height: shadowOffSetHeight)
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerradius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = Float(shadowOpacity)
        
    }
    

}
