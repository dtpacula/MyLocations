//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Derek Pacula on 2/12/16.
//  Copyright © 2016 Derek Pacula. All rights reserved.
//

import UIKit
import CoreLocation




class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    //Location Management
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    //Reverse Geocode
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    //Method Timer
    var methodTimer: NSTimer?
    
    @IBAction func getLocation() {
        
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation {
            
            stopLocationManager()
        }
            
        else {
            
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - CLLocatoinManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("didFailWithError \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        
        if let location = location {
            
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                
                print("We are done!")
                stopLocationManager()
                configureGetButton()
                
                if distance > 0 {
                    
                    performingReverseGeocoding = false
                }
            }
            
            print("Going into GEOCODING")
            if !performingReverseGeocoding {
                
                print("Geocode")
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {placemarks, error in print("Found Placemarks: \(placemarks), error: \(error)")
                    
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks where !p.isEmpty {
                        
                        self.placemark = p.last!
                    }
                    
                    else {
                        
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                
                
                })
            }
        }
        
        else if distance < 1.0 {
            
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                
                print("***Force Done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //Update the labels in the storyboard with the current location
    func updateLabels() {
        
        if let location = location {
            
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                
                addressLabel.text = stringFromPlacemark(placemark)
            }
            
            else if performingReverseGeocoding {
                
                addressLabel.text = "Searching for Address..."
            }
            
            else if lastGeocodingError != nil {
                
                addressLabel.text = "Error Finding Address"
            }
            
            else {
                
                addressLabel.text = "No Address Found"
            }
        }
        
        else {
            
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = true
            
            let statusMessage: String
            if let error = lastLocationError {
                
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    
                    statusMessage = "Location Services Disabled"
                }
                
                else
                {
                    statusMessage = "Error Getting Location"
                }
            }
            
            else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            }
            
            else if updatingLocation {
                
                statusMessage = "Searching.."
            }
            
            else {
                
                statusMessage = "Tap 'Get My Location' to Start"
            }
            
            messageLabel.text = statusMessage
        }
    }
    
    
    func startLocationManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            methodTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)

        }
        
    }
   
    func stopLocationManager() {
        
        if updatingLocation {
            if let methodTimer = methodTimer {
                methodTimer.invalidate()
            }
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
        }
    }
    
    func configureGetButton(){
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
        } else {
            getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var line1 = ""
        
        if let s = placemark.subThoroughfare {
            
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare {
            
            line1 += s
        }
        
        var line2 = ""
        
        if let s = placemark.locality {
            
            line2 += s + " "
        }
        
        if let s = placemark.administrativeArea {
            
            line2 += s + " "
        }
        
        if let s = placemark.postalCode {
            
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
    func didTimeOut() {
        print("*** Time out")
        
        if location == nil {
            
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            configureGetButton()
        }
    }


}

