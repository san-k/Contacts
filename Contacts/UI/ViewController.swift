//
//  ViewController.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate let dataSource: ContactsLoader & AvatarsLoader & FullAvatarLoader = NetworkDataSource()
    private var contacts: [Contact] = []
    private var contactAvatars: [ContactAvatar] = []
    
    @IBOutlet weak private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadContacts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource.suspendLoadAvatars()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resume()
    }
    
    func setup() {
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
    }
    
    func loadContacts() {
        dataSource.getContacts { contacts in
            DispatchQueue.main.async {
                self.contacts = contacts
                self.contactAvatars = contacts.map({ contact in
                    ContactAvatar(id: contact.id.value ?? UUID().uuidString)
                })
                self.tableView.reloadData()
            }
        } receiveError: { error in
            print(error)
            self.showError(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailsSegue",
           let destination = segue.destination as? DetailesViewController,
           let index = sender as? Int {
            destination.prepareWith(contact: contacts[index],
                                    avatar: contactAvatars[index],
                                    fullAvatarLoader: dataSource)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < contacts.count,
              let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as? ContactTableViewCell else { return UITableViewCell() }
        let name = "\(contacts[indexPath.row].name.first) \(contacts[indexPath.row].name.last)"
        cell.set(fullName: name, email: contacts[indexPath.row].email)
        
        if contactAvatars[indexPath.row].thumbnailState == .new {
            if !tableView.isDragging && !tableView.isDecelerating {
                dataSource.startDownload(for: contactAvatars[indexPath.row], at: indexPath.row) { index in
                    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            }
        }
        cell.upateAvatar(with: contactAvatars[indexPath.row])
        return cell
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dataSource.suspendLoadAvatars()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            resume()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resume()
    }
    
    func resume() {
        let visibleIndexes = Set<Int>((tableView.indexPathsForVisibleRows ?? []).map { $0.row })
        dataSource.loadImagesFor(visibleIndexes: visibleIndexes,
                                   contactAvatarGetter: { index in
                                       index < contacts.count ? contactAvatars[index] : nil
                                   },
                                   reloadCompletion: { index in
                                       self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                   })
        dataSource.resumeLoadAvatart()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetailsSegue", sender: indexPath.row)
    }
}

