//
//  DetailesViewController.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

class DetailesViewController: UIViewController {

    @IBOutlet weak private var avatarImage: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    
    private var contact: Contact!
    private var avatar: ContactAvatar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "\(contact.firstName) \(contact.lastName)"
        emailLabel.text = "\(contact.email)"
        updateAvatar()
    }
    
    
    func prepareWith(contact: Contact, avatar: ContactAvatar, fullAvatarLoader: FullAvatarLoader) {
        self.contact = contact
        self.avatar = avatar
        fullAvatarLoader.loadFullAvatar(for: avatar) {[weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateAvatar()
            }
        } receiveError: { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateAvatar()
                self.showError(error)
            }
        }
    }
    
    private func updateAvatar() {
        guard let avatarImage = self.avatarImage else { return }
        
        switch avatar.fullState {
        case .new, .downloading:
            avatarImage.image = UIImage(systemName: "person")
            avatarImage.image = UIImage(systemName: "person")
        case .downloaded:
            avatarImage.image = avatar.fullImage
        case .failed:
            avatar.fullImage = UIImage(systemName: "person.fill.xmark")
        }

    }

}
