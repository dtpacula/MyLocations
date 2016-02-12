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
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getLocation() {
        
        
        let authStatus = CLLocationManager.authorizationStatus()
        print("is this being called?")
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            print("is authorization being called?")
            return
        }
       
        print("after the if")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
      
    }
    
    // MARK: - CLLocatoinManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("didFailWithError \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        print("didUPdateLocations \(newLocation)")
    }


}

