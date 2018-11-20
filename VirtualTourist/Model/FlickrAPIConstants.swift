//
//  FlickrAPIConstants.swift
//  VirtualTourist
//
//  Created by Marisha Deroubaix on 13/11/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import UIKit

struct FlickrAPIConstants {
  
  static let key = "396862f225431f9246b9ac23b82e70c8"
  
  static let flickrPhotos = "https://api.flickr.com/services/rest?method=flickr.photos.search&format=json&api_key=\(FlickrAPIConstants.key)&bbox={bbox}&per_page=21&page={page}&extras=url_m&nojsoncallback=1"
  
}
