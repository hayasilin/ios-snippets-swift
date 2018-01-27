//
//  ViewController.swift
//  currentLocation_mapkit
//
//  Created by Kuan-Wei Lin on 8/22/15.
//  Copyright (c) 2015 Kuan-Wei Lin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {

    var flag: Bool!
    var region: MKCoordinateRegion!
    let locationManger = CLLocationManager()
    
    @IBOutlet weak var btnDeatil: UIBarButtonItem!
    @IBOutlet weak var btnShowLocation: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSegment: UISegmentedControl!
    
    
    override func viewDidAppear(animated: Bool) {
        if (CLLocationManager.locationServicesEnabled()){
            locationManger.requestAlwaysAuthorization()
            locationManger.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.flag = false
        mapView.delegate = self
        
        
        var latDelta: CLLocationDegrees!
        var longDelta: CLLocationDegrees!
        
        longDelta = 0.01
        latDelta = 0.01
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        
        
        let point1: MapViewAnnotation = MapViewAnnotation(lat: 25.013374, long: 121.541684, titleAnn: "台灣科技大學")
        let point2: MapViewAnnotation = MapViewAnnotation(lat: 25.012727, long: 121.543250, titleAnn: "公館國小")
        
        point1.setLocation()
        point2.setLocation()
        point1.setAnnotations("台灣科技大學1")
        point2.setAnnotations("公館國小1")
        
        let points = [point1, point2]
        
        /*
        var theRegion: MKCoordinateRegion = MKCoordinateRegionMake(point1.location!, span)
        mapView.setRegion(theRegion, animated: true)
        mapView.addAnnotation(point1.annotation)
        */
        
        
        //顯示大頭針
        for point in points{
            let theRegion: MKCoordinateRegion = MKCoordinateRegionMake(point.location!, span)
            self.mapView.setRegion(theRegion, animated: true)
            self.mapView.addAnnotation(point.annotation!)
        }

        
        
    }
    
    
    @IBAction func btnShowLocation(sender: UIBarButtonItem) {
        if flag != false{
            mapView.showsUserLocation = true
            flag = false
        }else{
            mapView.showsUserLocation = false
            flag = true
        }
    }
    
    @IBAction func showDetail(sender: UIBarButtonItem) {
        let region: MKCoordinateRegion = mapView.region
        
        print(region.center.latitude)
        print(region.center.longitude)
        print(region.span.latitudeDelta)
        print(region.span.longitudeDelta)
    }
    
    @IBAction func changeMapStyle(sender: UISegmentedControl) {
        switch mapSegment.selectedSegmentIndex{
        case 0:
            mapView.mapType = MKMapType.Standard
        case 1:
            mapView.mapType = MKMapType.Satellite
        case 2:
            mapView.mapType = MKMapType.Hybrid
        default:
            mapView.mapType = MKMapType.Standard
            mapSegment.selectedSegmentIndex = 0
        }
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let region: MKCoordinateRegion = mapView.region
        
        print(region.center.latitude)
        print(region.center.longitude)
        print(region.span.latitudeDelta)
        print(region.span.longitudeDelta)
    }
    
    /*
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var newAnnotation: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.title)
        
        newAnnotation.canShowCallout = true
        newAnnotation.animatesDrop = true
        newAnnotation.draggable = true
        
        return newAnnotation
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Ending{
            var droppedAt: CLLocationCoordinate2D = view.annotation.coordinate
            
            println("移動")
        }
    }
*/
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

