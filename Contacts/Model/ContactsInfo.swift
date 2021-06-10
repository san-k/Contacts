//
//  ContactsInfo.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import Foundation


struct ContactsResponse: Codable {
    struct ContactRaw: Codable {
        internal init(email: String, name: ContactRaw.Name, id: ContactRaw.Id) {
            self.email = email
            self.name = name
            self.id = id
        }
        
        struct Name: Codable {
            let first: String
            let last: String
        }
        struct Id: Codable {
            internal init(value: String?) {
                self.value = value
            }
            
            let value: String?
        }
        
        let email: String
        let name: Name
        let id: Id
    }

    var contacts: [Contact] {
        results.contacts
    }
    
    private let results: [ContactRaw]
}

extension Array where Element == ContactsResponse.ContactRaw {
    var contacts: [Contact] {
        map { (contactRaw: ContactsResponse.ContactRaw) -> Contact in
            let id = contactRaw.id.value.map { $0.replacingOccurrences(of: " ", with: "")} ?? UUID().uuidString
            return Contact(email: contactRaw.email,
                           firstName: contactRaw.name.first,
                           lastName: contactRaw.name.last,
                           id: id)
        }
    }
}


