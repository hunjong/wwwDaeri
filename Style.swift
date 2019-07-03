//
//  Style.swift
//  GoodDaeri
//
//  Created by hunjong choi on 13/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

import Foundation
import UIKit

let basicColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
let secondColor = UIColor(red: 0, green: 165/255, blue: 1, alpha: 1)

@IBDesignable
class DesignableView: UIView
{
}

extension UIView {
    
    @IBInspectable
    var colorPrimary: Bool {
        set {
            self.backgroundColor = basicColor
        }
        
        get {
            return self.backgroundColor == basicColor
        }
        
    }
    
    @IBInspectable
    var colorSecondary: Bool {
        set {
            self.backgroundColor = secondColor
        }
        
        get {
            return self.backgroundColor == secondColor
        }
        
    }
}
