//
//  ViewController.swift
//  Map
//
//  Created by user on 5/28/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import MapKit

class Pin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    init(pinTitle: String, pinCoord: CLLocationCoordinate2D) {
        self.coordinate = pinCoord
        self.title = pinTitle
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let manager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = true
        return locationManager
    } ()
    
    var itemMapFirst: MKMapItem!
    var itemMapTwo: MKMapItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        manager.delegate = self
        authorization()
        manager.startUpdatingLocation()
        pointsOnMap()
        let touch = UILongPressGestureRecognizer(target: self, action: #selector(addPin(recong:)))
        mapView.addGestureRecognizer(touch)
        
        }
    @objc func addPin(recong: UIGestureRecognizer) {
        let newLocation = recong.location(in: mapView)
        let newCoordinate = mapView.convert(newLocation, toCoordinateFrom: mapView)
        itemMapTwo = MKMapItem(placemark: MKPlacemark(coordinate: newCoordinate))
        let pin = Pin(pinTitle: "Конечный путь", pinCoord: newCoordinate)
        mapView.addAnnotation(pin)
        calculateRoute()
    }
    
    //zapolnenie karty massivom
    func pointsOnMap() {
        let arrayLat = [56.81, 54.81, 55.31]
        let arrayLon = [37.49, 38.00, 36.91]
        if arrayLat.count == arrayLon.count {
            for i in 0..<arrayLat.count {
                let point = MKPointAnnotation()
                point.title = ""
                point.coordinate = CLLocationCoordinate2D(latitude: arrayLat[i], longitude: arrayLon[i])
                self.mapView.addAnnotation(point)
            }
        }
    }
    
    func authorization() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print(location.coordinate)
            itemMapFirst = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        }
    }
    func calculateRoute() {
        let request = MKDirections.Request()
        request.source = itemMapFirst!
        request.destination = itemMapTwo!
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            guard let directionRespone = response else {
                print("Ошибка")
                return
            }
            let route = directionRespone.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.lineWidth = 4
        render.strokeColor = .red
        return render
    }


}

