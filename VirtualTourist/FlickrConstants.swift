//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Marisha Deroubaix on 13/11/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import UIKit

struct FlickrConstants {
  
  struct Flickr {
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    
    static let SearchBBoxHalfWidth = 1.0
    static let SearchBBoxHalfHeight = 1.0
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLonRange = (-180.0, 180.0)
  }
  
  struct FlickrParameterKeys {
    static let Method = "method"
    static let APIKey = "api_key"
    static let GalleryID = "gallery_id"
    static let Extras = "extras"
    static let Format = "format"
    static let NoJSONCallback = "nojsoncallback"
    static let SafeSearch = "safe_search"
    static let Text = "text"
    static let Bbox = "bbox"
    static let Page = "page"
    static let PerPage = "per_page"
  }
  
  struct FlickrParameterValues {
    static let SearchValueMethods = "flickr.photos.search"
    static let APIKey = "396862f225431f9246b9ac23b82e70c8"
    static let ValueFormat = "json"
    static let ValueNoJSONCallback = "1"
    static let GalleryPhotoMethod = "flickr.galleries.getPhotos"
    static let GalleryID = "5704-72157622566655097"
    static let MediumURL = "url_m"
    static let ValueSafeSearch = "1"
    static let PerPage = "100"
    
  }
  
  struct FlickrJSONKeys {
    
    static let Title = "title"
    static let UrlMedium = "url_m"
    static let Photos = "photos"
    static let Photo = "photo"
    static let Status = "stat"
    static let Pages = "pages"
    static let Total = "total"
    
  }
  
  struct FlickrJSONValues {
    
    static let StatusOK = "ok"
    
  }
}
