//
//  NetworkDataSource.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

class NetworkDataSource {
    private let session = URLSession(configuration: .default)
    private let avatarLoader = NetworkAvatarsLoader()
}

extension NetworkDataSource: AvatarsLoader {
    func startDownload(for contactAvatar: ContactAvatar?,
                       at index: Int,
                       reloadCompletion: @escaping (Int) -> Void) {
        avatarLoader.startDownload(for: contactAvatar,
                                   at: index,
                                   reloadCompletion: reloadCompletion)
    }
    
    func suspendLoadAvatars() {
        avatarLoader.suspend()
    }
    
    func resumeLoadAvatart() {
        avatarLoader.resume()
    }
    
    func loadImagesFor(visibleIndexes: Set<Int>,
                       contactAvatarGetter: (Int) -> ContactAvatar?,
                       reloadCompletion: @escaping (Int) -> Void) {
        avatarLoader.loadImagesFor(visibleIndexes: visibleIndexes,
                                   contactAvatarGetter: contactAvatarGetter,
                                   reloadCompletion: reloadCompletion)
    }
}

extension NetworkDataSource: FullAvatarLoader {
    func loadFullAvatar(for contactAvatar: ContactAvatar,
                        receiveValue: @escaping (UIImage?) -> Void,
                        receiveError: @escaping (ContactError) -> Void) {
        
        guard contactAvatar.fullState != .downloading else { return }
        if contactAvatar.fullState == .downloaded {
            receiveValue(contactAvatar.fullImage)
            return
        }
        
        let url = URL(string: contactAvatar.fullUrl)
        guard let request = url.map({ URLRequest(url: $0)}) else {
            contactAvatar.fullState = .failed
            receiveError(.badUrl)
            return
        }
        
        contactAvatar.fullState = .downloading
        let dataTask = session.dataTask(with: request) { data, _, error in
            if let error = error {
                contactAvatar.fullState = .failed
                receiveError(.urlSessionError(error))
                return
            }
            guard let data = data, !data.isEmpty else {
                contactAvatar.fullState = .failed
                receiveError(.noData)
                return
            }
            let image = UIImage(data: data)
            contactAvatar.fullState = .downloaded
            contactAvatar.fullImage = image
            receiveValue(image)
        }
        dataTask.resume()

    }
}

extension NetworkDataSource: ContactsLoader {
    func getContacts(receiveValue: @escaping ([Contact]) -> Void, receiveError: @escaping (ContactError) -> Void) {
        
        let url = URL(string: "https://randomuser.me/api/?results=200&inc=id,name,email&noinfo")
        guard let request = url.map({ URLRequest(url: $0)}) else {
            receiveError(.badUrl)
            return
        }
        
        let dataTask = session.dataTask(with: request) { data, _, error in
            if let error = error {
                receiveError(.urlSessionError(error))
                return
            }
            guard let data = data else {
                receiveError(.noData)
                return
            }

            do {
                let contactsRaw = try JSONDecoder().decode(ContactsResponse.self, from: data)
                receiveValue(contactsRaw.contacts)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
                receiveError(.decodeError(DecodingError.dataCorrupted(context)))
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
                receiveError(.decodeError(DecodingError.keyNotFound(key, context)))
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
                receiveError(.decodeError(DecodingError.valueNotFound(value, context)))
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
                receiveError(.decodeError(DecodingError.typeMismatch(type, context)))
            } catch {
                print("error: ", error)
                receiveError(.decodeError(error))
            }
        }
        dataTask.resume()
    }
}
