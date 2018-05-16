//
//  Coordinate.swift
//  GeofencesSwift
//
//  Created by usuario on 14/5/18.
//  Copyright © 2018 altran. All rights reserved.
//


import Foundation
class Coordinate {
    
    var id: Int
    var name: String?
    var latitude: Double
    var longitude: Double
    var radius: Int
    
    init(id: Int, name: String?, latitude: Double, longitude: Double, radius: Int){
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
}

