//
//  RoundedButton.swift
//  MealDeals
//
//  Created by Drew Scheffer on 5/9/21.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    
    var borderColor = UIColor.white.cgColor
    
    var highlightedColor = UIColor.white {
        didSet{
            if (isHighlighted){
                backgroundColor = highlightedColor
            }
        }
    }
    
    var defaultColor = UIColor.clear {
        didSet{
            if (!isHighlighted){
                backgroundColor = defaultColor
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet{
            if (isHighlighted){
                self.backgroundColor = highlightedColor
            }else{
                self.backgroundColor = defaultColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { //LIterally 0 clue what this is
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        self.layer.borderWidth = 2
        self.layer.borderColor = borderColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
