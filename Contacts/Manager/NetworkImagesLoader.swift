//
//  AvatarLoadManager.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import Foundation


class NetworkAvatarsLoader {
    
    private var downloadsInProgress: [Int: Operation] = [:]
    private var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download avatars queue"
        queue.maxConcurrentOperationCount = 4
        return queue
    }()
    
    func suspend() {
      downloadQueue.isSuspended = true
    }
    
    func resume() {
      downloadQueue.isSuspended = false
    }
 
    func loadImagesFor(visibleIndexes: Set<Int>,
                       contactAvatarGetter: (Int) -> ContactAvatar?,
                       reloadCompletion: @escaping (Int) -> Void) {
        
        let allPendingOperationsIndexes: Set<Int> = Set(downloadsInProgress.keys)
        let toBeCancelled = allPendingOperationsIndexes.subtracting(visibleIndexes)
        let toBeStarted = visibleIndexes.subtracting(allPendingOperationsIndexes)
        
        for index in toBeCancelled {
            if let pendingDownload = downloadsInProgress[index] {
                pendingDownload.cancel()
            }
            downloadsInProgress.removeValue(forKey: index)
        }
        
        for index in toBeStarted {
            startDownload(for: contactAvatarGetter(index), at: index, reloadCompletion: reloadCompletion)
        }
    }
    
    private func startDownload(for contactAvatar: ContactAvatar?,
                       at index: Int,
                       reloadCompletion: @escaping (Int) -> Void) {
        
        guard let contactAvatar = contactAvatar else { return }
        guard case ContactAvatar.State.new = contactAvatar.state else { return }
        
        guard downloadsInProgress[index] == nil else {
            return
        }
        
        let downloader = AvatarLoaderOperation(contactAvatar)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.downloadsInProgress.removeValue(forKey: index)
                reloadCompletion(index)
            }
        }
        downloadsInProgress[index] = downloader
        downloadQueue.addOperation(downloader)
    }
    
}
