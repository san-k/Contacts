//
//  ContactsInfo.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import Foundation


struct ContactsResponse<T> where T: Codable {
    let results: T
}

extension ContactsResponse: Codable {}
