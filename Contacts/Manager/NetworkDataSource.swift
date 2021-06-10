//
//  NetworkDataSource.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

class NetworkDataSource {
    private let session = URLSession(configuration: URLSessionConfiguration.default)
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
                        receiveValue: @escaping () -> Void,
                        receiveError: @escaping (ContactError) -> Void) {
        
        guard contactAvatar.fullState != .downloading else { return }
        if contactAvatar.fullState == .downloaded {
            receiveValue()
            return
        }
        
        let url = URL(string: contactAvatar.fullUrl)
        guard let request = url.map({ URLRequest(url: $0)}) else {
            contactAvatar.fullState = .failed
            receiveError(.badUrl)
            return
        }
        
        contactAvatar.fullState = .downloading
        let downloadTask = session.downloadTask(with: request) { location, _, error in
            if let error = error {
                contactAvatar.fullState = .failed
                receiveError(.urlSessionError(error))
                return
            }
            
            guard let location = location else {
                contactAvatar.fullState = .failed
                receiveError(.noData)
                return
            }
            
            guard let savedLocation = contactAvatar.savedLocation else {
                contactAvatar.fullState = .failed
                receiveError(.locationError)
                return
            }

            do {
                try FileManager.default.moveItem(at: location, to: savedLocation)
                contactAvatar.fullState = .downloaded
                receiveValue()
            } catch {
                contactAvatar.fullState = .failed
                receiveError(.locationError)
            }
        }
        downloadTask.resume()
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
