//
//  DataSource.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

protocol ContactsLoader {
    func getContacts(receiveValue: @escaping ([Contact]) -> Void, receiveError: @escaping (ContactError) -> Void)
}

protocol AvatarsLoader {
    func suspendLoadAvatars()
    func resumeLoadAvatart()
    func startDownload(for contactAvatar: ContactAvatar?,
                       at index: Int,
                       reloadCompletion: @escaping (Int) -> Void)
    func loadImagesFor(visibleIndexes: Set<Int>,
                       contactAvatarGetter: (Int) -> ContactAvatar?,
                       reloadCompletion: @escaping (Int) -> Void)
}

protocol FullAvatarLoader {
    func loadFullAvatar(for contactAvatar: ContactAvatar,
                        receiveValue: @escaping (UIImage?) -> Void,
                        receiveError: @escaping (ContactError) -> Void)

}
