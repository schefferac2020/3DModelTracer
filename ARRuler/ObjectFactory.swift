//
//  ObjectFileFactory.swift
//  ARRuler
//
//  Created by Drew Scheffer on 7/7/21.
//

import Foundation

class ObjectFactory{
    var object_string : String?
    
    func createObjectFormattedString() {
        var writeString = "v 0.000000 2.000000 0.000000\n"
        writeString += "v 0.000000 0.000000 0.000000\n"
        writeString += "v 2.000000 0.000000 0.000000\n"
        writeString += "v 2.000000 2.000000 0.000000\n"
        writeString += "v 4.000000 0.000000 -1.255298\n"
        writeString += "v 4.000000 2.000000 -1.255298\n"
        writeString += "v 2.000000 0.000000 -2.000000\n"
        writeString += "v 2.000000 2.000000 -2.000000\n"

        writeString += "v 0.000000 0.000000 -2.000000\n"
        writeString += "v 0.000000 2.000000 -2.000000\n"


        writeString += "# 6 vertices\n"

        writeString += "g all\n"
        writeString += "s 1\n"
        writeString += "f 1 2 3 4\n"
        writeString += "f 4 3 5 6\n"
        writeString += "f 6 5 7 8\n"
        writeString += "f 8 7 9 10\n"
        writeString += "f 10 9 2 1\n"
        writeString += "f 1 4 6 8 10\n"
        
        
        self.object_string = writeString
        
    }
}
