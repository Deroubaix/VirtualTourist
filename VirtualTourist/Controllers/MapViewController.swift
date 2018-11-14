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

class MapViewController: UIViewController, UIGestureRecognizerDelegate  {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var editButton: UIBarButtonItem!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  @IBOutlet weak var deleteTextLabel: UILabel!
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var annotations = [MKPointAnnotation]()
  
  var fetchPinResultsController: NSFetchedResultsController<Pin>!
  let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
  let sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                         NSSortDescriptor(key: "longitude", ascending: false)]
  var deletedAllowed = false
  var appStarted = false
  

  override func viewDidLoad() {
    super.viewDidLoad()
    doneButton.isEnabled = false
    deleteTextLabel.isHidden = true
  }
  
  @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
    
    deleteTextLabel.frame.origin.y = view.frame.height
    deleteTextLabel.isHidden = false
    doneButton.isEnabled = true
    editButton.isEnabled = false
    
    UIView.beginAnimations(nil, context: nil)
    deleteTextLabel.frame.origin.y -= deleteTextLabel.frame.height
    mapView.frame.origin.y -= deleteTextLabel.frame.height
    UIView.commitAnimations()
  }
  

  @IBAction func doneEditingPressed(_ sender: UIBarButtonItem) {
    doneButton.isEnabled = false
    editButton.isEnabled = true
    deleteTextLabel.frame.origin.y = view.frame.height - deleteTextLabel.frame.height
    
    UIView.beginAnimations(nil, context: nil)
    deleteTextLabel.frame.origin.y = view.frame.height
    mapView.frame.origin.y = 0
    UIView.commitAnimations()
  }
  
}

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    let reuseID = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
    
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
      pinView?.pinTintColor = .red
    } else {
      pinView?.annotation = annotation
    }
    
    return pinView
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
    fetchRequest.sortDescriptors = sortDescriptors
    
    let predicateOne = NSPredicate(format: "latitude = %@", argumentArray: [(view.annotation?.coordinate.latitude)!])
    let predicateTwo = NSPredicate(format: "longitude = %@", argumentArray: [(view.annotation?.coordinate.longitude)!])
    let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateOne, predicateTwo])
    fetchRequest.predicate = predicate
    
    let pinResults = fetchPinResultsController.fetchedObjects
    let selectedPin = pinResults![0]
    
    if deletedAllowed {
      var index = 0
      
      for i in annotations {
        if selectedPin.latitude as! Double == i.coordinate.latitude && selectedPin.longitude as! Double == i.coordinate.longitude {
          mapView.removeAnnotations(annotations)
          annotations.remove(at: index)
          fetchPinResultsController.managedObjectContext.delete(selectedPin)
          appDelegate.stack?.save()
          return
        }
        index += 1
      }
    } else {
      let collectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
      
      self.navigationController?.pushViewController(collectionViewController, animated: true)
      mapView.deselectAnnotation(view.annotation, animated: false)
      deleteTextLabel.isHidden = true
    }
    
  }
  
}

