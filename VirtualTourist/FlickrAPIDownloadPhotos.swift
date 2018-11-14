//
//  FlickrAPIDownloadPhotos.swift
//  VirtualTourist
//
//  Created by Marisha Deroubaix on 13/11/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FlickrAPIDownloadPhotos {
  
  let delegate = UIApplication.shared.delegate as! AppDelegate
  
  func flickrURLParameters(_ parameters: [String: AnyObject]) -> URL {
    
    var components = URLComponents()
    components.scheme = FlickrAPIConstants.Flickr.APIScheme
    components.host = FlickrAPIConstants.Flickr.APIHost
    components.path = FlickrAPIConstants.Flickr.APIPath
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
      let queryItem = URLQueryItem(name: key, value: "\(value)")
      components.queryItems?.append(queryItem)
    }
    
    return components.url!
  }
  
  func downloadImageFrom(_ pin: Pin, completionHandler: @escaping (_ results: [[String:AnyObject]]?, _ pagesNumber: Int, _ error: String?) -> Void) {
    
    let page = randomPage((pin.pages as? Int)!)
    
    let methodParams: [String: String?] =
      
      [FlickrAPIConstants.FlickrParameterKeys.Method:FlickrAPIConstants.FlickrParameterValues.SearchValueMethods,
       FlickrAPIConstants.FlickrParameterKeys.APIKey: FlickrAPIConstants.FlickrParameterValues.APIKey,
       FlickrAPIConstants.FlickrParameterKeys.Bbox: bBoxString((pin.latitude as? Double)!, Longitude: (pin.longitude as? Double)!),
       FlickrAPIConstants.FlickrParameterKeys.Extras: FlickrAPIConstants.FlickrParameterValues.MediumURL, FlickrAPIConstants.FlickrParameterKeys.Page: String(page), FlickrAPIConstants.FlickrParameterKeys.Format: FlickrAPIConstants.FlickrParameterValues.ValueFormat,
       FlickrAPIConstants.FlickrParameterKeys.NoJSONCallback: FlickrAPIConstants.FlickrParameterValues.ValueNoJSONCallback]
    
    let request = URLRequest(url: flickrURLParameters(methodParams as [String: AnyObject]))
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      func errorFound(_ error: String) {
        print(error)
        completionHandler(nil, 0 , error)
      }
      
      guard error == nil else {
        errorFound((error?.localizedDescription)!)
        return
      }
      
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        errorFound("Status Code was \(String(describing: response as? HTTPURLResponse))?.statusCode), which is not whithin the 200 to 299 range")
        return
      }
      
      guard let data = data else {
        errorFound("No data returned")
        return
      }
      
      var parsedData: AnyObject!
      
      do {
        parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
      } catch {
        errorFound("Unable to successfully parse data")
      }
      
      guard let photoDictionary = parsedData["photos"] as? [String: AnyObject] else {
        return
      }
      
      guard let pagesNumber = photoDictionary["pages"] as? Int else {
        return
      }
      
      guard let photoArray = photoDictionary["photo"] as? [[String:AnyObject]] else {
        return
      }
      
      let finalPhotoArray = self.photos(photoArray)
      
      completionHandler(finalPhotoArray, pagesNumber, nil)
    }
    task.resume()
  }
  
  func randomPage(_ pages: Int) -> Int {
    
    var pageChoosen = Int()
    
    if pages == 0 {
      pageChoosen = 1
    } else {
      pageChoosen = Int(arc4random_uniform(UInt32((pages))))
    }
    return pageChoosen
  }
  
  func photos(_ photoArray: [[String: AnyObject]]) -> [[String: AnyObject]] {
    
    let number = Int(arc4random_uniform(UInt32(photoArray.count - 21)))
    
    var photoNumber = 0
    var photoLimit = 0
    var finalPhotoArray = [[String: AnyObject]]()
    
    for i in photoArray {
      if photoNumber >= number {
        if photoLimit < 21 {
          finalPhotoArray.append(i)
          photoLimit += 1
        }
      }
      photoNumber += 1
    }
    return finalPhotoArray
  }
  
  func bBoxString(_ Latitute: Double, Longitude: Double) -> String {
    
    let minimumLongitude = (Longitude + FlickrAPIConstants.Flickr.SearchBBoxHalfWidth, FlickrAPIConstants.Flickr.SearchLonRange.1)
    let maximumLongitude = (Longitude - FlickrAPIConstants.Flickr.SearchBBoxHalfWidth, FlickrAPIConstants.Flickr.SearchLonRange.0)
    let minimumLatitude = (Latitute + FlickrAPIConstants.Flickr.SearchBBoxHalfHeight, FlickrAPIConstants.Flickr.SearchLatRange.1)
    let maximunLatitude = (Latitute - FlickrAPIConstants.Flickr.SearchBBoxHalfHeight, FlickrAPIConstants.Flickr.SearchLatRange.0)
    
    return "\(maximumLongitude), \(maximunLatitude), \(minimumLongitude), \(minimumLatitude)"
  }
}
