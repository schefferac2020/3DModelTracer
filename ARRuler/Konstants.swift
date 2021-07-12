//
//  Konstants.swift
//  ARRuler
//
//  Created by Drew Scheffer on 6/8/21.
//

import Foundation
import UIKit

struct K {
    struct Image {
        struct Indicator {
            static let green = #imageLiteral(resourceName: "circle")
            static let red = #imageLiteral(resourceName: "World")
        }
        
        static let done = #imageLiteral(resourceName: "backArrow")
        static let place = #imageLiteral(resourceName: "house")
        static let export = #imageLiteral(resourceName: "userIcon")
    }
    struct Segues {
        static let toModify = "ToModify"
        //static let backToCamera = "backToCamera"
    }
}
