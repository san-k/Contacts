//
//  AvatarDownloader.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

class ImageLoaderOperation: Operation {
  let contactAvatar: ContactAvatar
  
  init(_ contactAvatar: ContactAvatar) {
    self.contactAvatar = contactAvatar
  }
  
  override func main() {
    if isCancelled {
      return
    }
    
    guard let imageData = URL(string: contactAvatar.thumbnailUrl).flatMap({ try? Data(contentsOf: $0) }) else { return }
    
    if isCancelled {
      return
    }
    
    if !imageData.isEmpty {
      contactAvatar.thumbnailImage = UIImage(data:imageData)
      contactAvatar.state = .downloaded
    } else {
      contactAvatar.state = .failed
      contactAvatar.thumbnailImage = nil
    }
  }
}
