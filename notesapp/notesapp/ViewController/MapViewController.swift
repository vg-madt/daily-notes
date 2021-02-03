//
//  MapViewController.swift
//  notesapp
//
//  Created by admin on 6/20/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocation!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        addPin()
        // Do any additional setup after loading the view.
    }
    
    func addPin(){
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = location.coordinate
        //myAnnotation.title = "Your note was created here"
        self.mapView.addAnnotation(myAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let id = MKMapViewDefaultAnnotationViewReuseIdentifier
        if let v = mapView.dequeueReusableAnnotationView(withIdentifier: id, for: annotation) as? MKMarkerAnnotationView{
           // v.titleVisibility = .visible
            v.markerTintColor = .blue
            let annotationLabel = UILabel(frame: CGRect(x: 0, y: 40, width: 250, height: 60))
            annotationLabel.alpha = 10
            annotationLabel.text = "Your note was created here"
            annotationLabel.backgroundColor = UIColor.white
            v.addSubview(annotationLabel)
            v.canShowCallout = true
            v.frame = annotationLabel.frame
            return v
        }
        
        return nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


//final code
