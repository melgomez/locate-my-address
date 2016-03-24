//
//  MapLocation.swift
//  MapMe
//
//  Created by Mel Gomez on 23/03/2016.
//  Copyright © 2016 meldarrelgomez. All rights reserved.
//

import Foundation
import MapKit

class MapLocation : NSObject, MKAnnotation, NSCoding {
    
    var street: String!
    var city: String!
    var state: String!
    var zip: String!
    var _coordinate: CLLocationCoordinate2D!
    
    var title: String? {
        get {
            return NSLocalizedString("You are Here", comment: "You are Here")
        }
    }
    
    var subtitle: String? {
        get {
            var result = ""
            
            if self.street != nil {
                result += self.street
        
                if self.city != nil || self.state != nil || self.zip != nil {
                    result += ", "
                }
            }
            
            if self.city != nil {
                result += self.city
                
                if self.state != nil {
                    result += ", "
                }
            }
            
            if self.state != nil {
                result += self.state
            }
            
            if self.zip != nil {
                result += " " + self.zip
            }
            return result
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return _coordinate
        }
        set {
            _coordinate = newValue
        }
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.street, forKey:"street")
        aCoder.encodeObject(self.city, forKey:"city")
        aCoder.encodeObject(self.state, forKey:"state")
        aCoder.encodeObject(self.zip, forKey:"zip")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        self.street = aDecoder.decodeObjectForKey("street") as? String
        self.city = aDecoder.decodeObjectForKey("city") as? String
        self.state = aDecoder.decodeObjectForKey("state") as? String
        self.zip = aDecoder.decodeObjectForKey("zip") as? String
    }
    override init(){
        super.init()
    }
}