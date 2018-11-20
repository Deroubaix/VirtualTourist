//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Marisha Deroubaix on 15/11/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class CollectionViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var newCollectionButton: UIBarButtonItem!
  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  
  var pin: Pin!
  var photos = [Photos]()
  var photosToDelete = [Photos]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getPhotos()
    setupMapView()
    setFlowLayout()
  }
  
  
  @IBAction func newCollectionPressed(_ sender: UIBarButtonItem) {
    
    if photosToDelete.count == 0 {
      for photo in photos {
        DataController.shared.context.delete(photo)
      }
      DataController.shared.save()
      photos = [Photos]()
      collectionView.reloadData()
      getPhotos()
    } else {
      for photo in photosToDelete {
        DataController.shared.context.delete(photo)
        photos.remove(at: photos.index(of: photo)!)
      }
      photosToDelete = [Photos]()
      DataController.shared.save()
      collectionView.reloadData()
    }
    updateToolBar()
  }
  
  func getPhotos() {
    
    if let fetchResults = fetchPhotos() {
      photos = fetchResults
    } else {
      FlickrAPIDownloadPhotos.shared.getPhotos(with: pin.latitude, longitude: pin.longitude) { (photoURL, error) in
        if let photoURL = photoURL {
          for url in photoURL {
            let photo = Photos(context: DataController.shared.context)
            photo.imageURL = url
            photo.pin = self.pin
            self.photos.append(photo)
          }
          DataController.shared.save()
          DispatchQueue.main.async {
            self.collectionView.reloadData()
          }
        }
      }
    }
  }
  
  func fetchPhotos() -> [Photos]? {
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
    let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
    fetchRequest.predicate = predicate
    
    do {
      if let result = try DataController.shared.context.fetch(fetchRequest) as? [Photos] {
        return result.count > 0 ? result : nil
      }
    } catch {
      print("Error getting data")
    }
    return nil
  }
  
  func setupMapView() {
    let annotation = MKPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(pin.latitude), CLLocationDegrees(pin.longitude))
    mapView.addAnnotation(annotation)
    let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  func updateToolBar() {
    newCollectionButton.title = photosToDelete.count > 0 ? "Delete photos" : "New Collection"
    newCollectionButton.tintColor = photosToDelete.count > 0 ? .red : view.tintColor
  }
  
  func setFlowLayout() {
    collectionView.allowsMultipleSelection = true
    
    let space: CGFloat = 3.0
    let dimension = (view.frame.size.width - (2 * space)) / 3.0
    flowLayout.minimumInteritemSpacing = space
    flowLayout.minimumLineSpacing = space
    flowLayout.itemSize = CGSize(width: dimension, height: dimension)
  }
  
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as! Cell
    let photo = photos[indexPath.row]
    cell.activityIndicator.isHidden = false
    cell.collectionImage.image = nil
    cell.contentView.alpha = photosToDelete.contains(photo) ? 0.4 : 1.0
    
    if let imageData = photo.image {
      let image = UIImage(data: imageData as Data)
      cell.collectionImage.image = image
      cell.activityIndicator.isHidden = true
    } else {
      cell.activityIndicator.startAnimating()
      FlickrAPIDownloadPhotos.shared.downloadImage(with: photo.imageURL!) { (data, error) in
        if error == nil {
          let downloadedImage = UIImage(data: data!)
          photo.image = data
          
          DispatchQueue.main.async {
            cell.collectionImage.image = downloadedImage
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
          }
        }
      }
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let cell = collectionView.cellForItem(at: indexPath)
    cell?.contentView.alpha = 0.4
    
    let photo = photos[indexPath.row]
    if !photosToDelete.contains(photo) {
      photosToDelete.append(photo)
    }
    updateToolBar()
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
    let cell = collectionView.cellForItem(at: indexPath)
    let photo = photos[indexPath.row]
    
    if photosToDelete.contains(photo) {
      cell?.contentView.alpha = 1.0
      photosToDelete.remove(at: photosToDelete.index(of: photo)!)
    }
    updateToolBar()
  }
  
}
