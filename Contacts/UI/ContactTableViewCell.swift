//
//  ContactTableViewCell.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak private var avatarView: UIImageView!
    @IBOutlet weak private var fullNameLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
    }
    
    func set(fullName: String, email: String) {
        fullNameLabel.text = fullName
        emailLabel.text = email
    }
    
    func upateAvatar(with contactAvatar: ContactAvatar) {
        switch contactAvatar.thumbnailState {

        case .new:
            avatarView.image = UIImage.init(systemName: "person")
        case .downloaded:
            avatarView.image = contactAvatar.thumbnailImage
        case .failed:
            avatarView.image = UIImage(systemName: "person.fill.xmark")
        }
    }
    
}
