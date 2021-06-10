//
//  ContactError.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import Foundation

enum ContactError: Error {
    case badUrl
    case noData
    case locationError
    case urlSessionError(Error)
    case decodeError(Error)
}
