//
//  ContactAvatar.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

class ContactAvatar {
    init(id: String) {
        self.id = id
        self.url = "https://picsum.photos/seed/\(id)"
    }
    
    enum ThumbnailState {
        case new
        case downloaded
        case failed
    }
    
    enum FullState {
        case new
        case downloading
        case downloaded
        case failed
    }
    
    let id: String
    var thumbnailState = ThumbnailState.new
    var fullState = FullState.new
    var thumbnailImage: UIImage?
    var fullImage: UIImage?
    
    
    var thumbnailUrl: String { url + "/79"}
    var fullUrl: String { url + "/5000"}
    
    private let url: String

}


