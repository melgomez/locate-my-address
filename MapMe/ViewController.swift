//
//  ViewController.swift
//  MapMe
//
//  Created by Mel Gomez on 23/03/2016.
//  Copyright © 2016 meldarrelgomez. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func findMe(sender: AnyObject) {
        
        if manager == nil {
            manager = CLLocationManager()
        }
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        mapView.delegate = self
        
        
        self.progressBar.hidden = false
        self.progressBar.progress = 0.0
        self.progressLabel.text = NSLocalizedString("Determining Current Location", comment: "Determining Current Location")
        
        
        self.button.hidden = true
    }
    
    var manager: CLLocationManager!
    var geocoder: CLGeocoder!
    var placemark: CLPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.mapType = MKMapType.Standard
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - (Private) Instance Methods
    
    func openCallout(annotation: MKAnnotation) {
        self.progressBar.progress = 1.0
        self.progressLabel.text = NSLocalizedString("Showing Annotation", comment: "Showing Annotation")
        
        self.mapView.selectAnnotation(annotation, animated: true)
        
        self.button.hidden = true
        self.progressBar.hidden = true
        self.progressLabel.text = " "
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(OKAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reverseGeocode(location: CLLocation) {
        if geocoder == nil {
            geocoder = CLGeocoder()
            print("geocoder is set")
        } else {
            print("geocoder is nil")
        }
        
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            (placemark, error) -> Void in
            
            if  (nil != error) {
                let title = NSLocalizedString("Error translating coordinates into location", comment: "Error translating coordinates into location")
                
                let message = NSLocalizedString("Geocoder did not recognize coordinates", comment: "Geocoder did not recognize coordinates")
                
                self.showAlert(title, message: message)
            } else if placemark!.count > 0 {
                
                let placemark: CLPlacemark = placemark![0] as CLPlacemark
                
                self.progressBar.progress = 0.5
                self.progressLabel.text = NSLocalizedString("Location Determined", comment: "Location Determined")
                
                let annotation = MapLocation()
                annotation.street = placemark.thoroughfare
                annotation.city = placemark.locality
                annotation.state = placemark.administrativeArea
                annotation.zip  = placemark.postalCode
                annotation.coordinate = location.coordinate
                
                self.mapView.addAnnotation(annotation)
//                self.mapView.viewForAnnotation(annotation)
            }
        })
        
    }
    
    //MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let oldLocation: CLLocation = locations.first! as CLLocation
        let newLocation: CLLocation = locations.last! as CLLocation
        
        if newLocation.timestamp.timeIntervalSince1970 < NSDate.timeIntervalSinceReferenceDate() - 60 {
            return
        }
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
        
        manager.delegate = nil
        manager.stopUpdatingLocation()
        
        self.progressBar.progress = 0.25
        self.progressLabel.text = NSLocalizedString("Reverse Geocoding Location", comment: "Reverse Geocoding Location")
        
        self.reverseGeocode(newLocation)
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let errorType = error.code == CLError.Denied.rawValue ? NSLocalizedString("Access Denied", comment: "Access Denied") : NSLocalizedString("Unknown Error", comment: "Unknown Error")
        
        let title = NSLocalizedString("Error getting Location", comment: "Error getting Location")
        showAlert(title, message: errorType)
    }
    
    
    // MARK: - MKMapViewDelegate Methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let placemarkIdentifier = "Map Location Identifier"
        print(placemarkIdentifier)
        if let _annotation = annotation as? MapLocation {
            var annotationView: MKPinAnnotationView!
            
            if let _annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(placemarkIdentifier) as? MKPinAnnotationView {
                annotationView = _annotationView
            } else {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: placemarkIdentifier)
            }
            
            annotationView.enabled = true
            annotationView.animatesDrop = true
            annotationView.canShowCallout = true
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.openCallout(annotation)
            })
            
            self.progressBar.progress = 0.75
            self.progressLabel.text = NSLocalizedString("Creating Annotation", comment: "Creating Annotation")
            
            return annotationView
        }
        return nil
    }
}

