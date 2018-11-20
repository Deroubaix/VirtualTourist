//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Marisha Deroubaix on 12/11/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate  {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var editButton: UIBarButtonItem!
  @IBOutlet weak var deletePinConstraint: NSLayoutConstraint!
  
  var deleteAllowed = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
    
    do {
      if let result = try DataController.shared.context.fetch(fetchRequest) as? [Pin] {
        for pin in result {
          let annotation = MKPointAnnotation()
          annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
          mapView.addAnnotation(annotation)
        }
      }
    } catch {
      print("Couldn't find any Pins")
    }
  }
  
  
  @IBAction func viewPressedToAddPin(_ sender: UILongPressGestureRecognizer) {
    
    if sender.state == .began {
      let touchedMap = sender.location(in: mapView)
      let coordinates = mapView.convert(touchedMap, toCoordinateFrom: mapView)
      let pin = Pin(context: DataController.shared.context)
      pin.latitude = Double(coordinates.latitude)
      pin.longitude = Double(coordinates.longitude)
      DataController.shared.save()
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinates
      mapView.addAnnotation(annotation)
    }
  }
  
  
  @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
    
    deletePinConstraint.constant = deletePinConstraint.constant == 0 ? -64.0 : 0
    editButton.title = deletePinConstraint.constant == 0 ? "Edit" : "Done"
    deleteAllowed = deletePinConstraint.constant == 0 ? false : true
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    var pinView: MKPinAnnotationView
    
    if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView {
      dequeuedView.annotation = annotation
      pinView = dequeuedView
    } else {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
      pinView.animatesDrop = true
    }
    
    return pinView
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
    mapView.deselectAnnotation(view.annotation, animated: true)
    if let annotation = view.annotation {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
      let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [annotation.coordinate.latitude, annotation.coordinate.longitude])
      fetchRequest.predicate = predicate
      
      do {
        if let result = try DataController.shared.context.fetch(fetchRequest) as? [Pin],
          let pin = result.first {
          if deleteAllowed {
            DataController.shared.context.delete(pin)
            DataController.shared.save()
            mapView.removeAnnotation(annotation)
          } else {
            performSegue(withIdentifier: "goToCollectionView", sender: pin )
          }
        }
      } catch {
        print("Couln't find any Pins")
      }
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToCollectionView" {
      let viewController = segue.destination as! CollectionViewController
      viewController.pin = sender as? Pin
    }
  }
  
}

