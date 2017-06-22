//
//  ViewController.swift
//  PerimeterCheck
//
//  Created by Matthew Bowen on 5/22/17.
//  Copyright © 2017 Matthew Bowen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var updateMapPosition = false
    var pinLocationData: Array<CLLocationCoordinate2D> = Array()
    var lastLocation: CLLocationCoordinate2D? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        //mapView.mapType = MKMapType.satellite
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation:CLLocationCoordinate2D = manager.location!.coordinate
        if (updateMapPosition) {
            addPinToMap(location: currentLocation)
            updateMapPosition = !updateMapPosition
        }
        
        lastLocation = currentLocation
    }
    
    func addPinToMap(location: CLLocationCoordinate2D?){
        if(location != nil){
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude:(location?.longitude)!)
            annotation.coordinate = centerCoordinate
            annotation.title = "CurrentLocation"
            mapView.addAnnotation(annotation)
            mapView.showAnnotations(self.mapView.annotations, animated: true)
            pinLocationData.append(location!)
        }
    }
    
    func createPolyline() {
        let geodesic = MKGeodesicPolyline(coordinates: pinLocationData, count: pinLocationData.count)
        mapView.add(geodesic)
    }
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func removeAnotations() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
    }
    
    func screenShotMethod() {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        displayAlert(alertTitle: "Success", alertMessage: "Image successfully saved")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
        renderer.alpha = 0.5
        renderer.strokeColor = UIColor.blue
        
        return renderer
    }
    
    @IBAction func setPin(_ sender: Any) {
        addPinToMap(location: lastLocation)
    }
    
    @IBAction func drawBorder(_ sender: Any) {
        createPolyline()
        removeAnotations()
    }
    
    @IBAction func drawLine(_ sender: Any, forEvent event: UIEvent) {
        //let t: UITouch = event.allTouches!.first!
    }
    
    @IBAction func saveView(_ sender: Any) {
        screenShotMethod()
    }
}

