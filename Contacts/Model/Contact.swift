//
//  Contact.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import Foundation

struct Contact: Codable {
    internal init(email: String, name: Contact.Name, id: Contact.ID) {
        self.email = email
        self.name = name
        self.id = id
    }
    
    struct Name: Codable {
        let first: String
        let last: String
    }
    struct ID: Codable {
        internal init(value: String?) {
            self.value = value
        }
        
        let value: String?
    }
    
    let email: String
    let name: Name
    let id: ID
}
