//
//  AvatarDownloader.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

class AvatarLoaderOperation: Operation {
  let contactAvatar: ContactAvatar
  
  init(_ contactAvatar: ContactAvatar) {
    self.contactAvatar = contactAvatar
  }
  
  override func main() {
    if isCancelled {
      return
    }
    
    guard let imageData = URL(string: contactAvatar.thumbnailUrl).flatMap({ try? Data(contentsOf: $0) }) else { return }
    
    if !imageData.isEmpty {
      contactAvatar.thumbnailImage = UIImage(data:imageData)
        contactAvatar.thumbnailState = .downloaded
    } else {
      contactAvatar.thumbnailState = .failed
      contactAvatar.thumbnailImage = nil
    }
  }
}
