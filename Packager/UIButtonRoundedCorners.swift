//
//  UIButtonRoundedCorners.swift
//  Packager
//
//  Created by Gijsbert te Paske on 11/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import UIKit

class ButtonRoundedCorners : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.height/3
        
    }
}
