//
//  LogoImageView.swift
//  Stocks
//
//  Created by shox on 11.09.2018.
//  Copyright © 2018 VladimirYakutin. All rights reserved.
//

import UIKit

class LogoImageView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius =  frame.height/2
        layer.masksToBounds = false
        
        clipsToBounds = true
    }
    
    func configure(with image: UIImage) {
        self.image = image
    }
}
