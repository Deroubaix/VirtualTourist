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

