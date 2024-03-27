//
//  File.swift
//  
//
//  Created by Dan Carlson on 2024-03-08.
//

import Foundation

public extension ContactClient {

    public static let live = Self(
        contactwithID: { id in
            return liveContacts.first(where: { $0.id == id })
        }, contactsMatchingName: { firstName, lastName in
            let firstAndLastMatches = liveContacts.filter{ contact in
                contact.first == firstName && contact.last == lastName
            }
            if firstAndLastMatches.count > 0 { return firstAndLastMatches }
            let lastMatches = liveContacts.filter{ contact in
                contact.last == lastName
            }
            let firstMatches = liveContacts.filter{ contact in
                contact.first == firstName
            }
            let matches = lastMatches + firstMatches
            return matches
        }
    )
}
