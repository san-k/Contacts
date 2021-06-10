//
//  Contact.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import Foundation

struct Contact {
    internal init(email: String, firstName: String, lastName: String, id: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
    }

    let email: String
    let firstName: String
    let lastName: String
    let id: String
}


