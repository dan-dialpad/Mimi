//
//  ContactHelper.swift
//  RudyExtension
//
//  Created by Dan Carlson on 2024-03-21.
//

import Foundation
import Models
import Intents

extension Contact {
    var asINPerson: INPerson {
        let handle = INPersonHandle(value: phone, type: .phoneNumber)
        let nameComponents = PersonNameComponents(givenName: first, familyName: last)
        let displayName = "\(first) \(last)"
        let image = URL(string: imageUrl).flatMap { INImage(url: $0) }
        let customIdentifier = id
        return INPerson(personHandle: handle,
                        nameComponents: nameComponents,
                        displayName: displayName,
                        image: image,
                        contactIdentifier: nil,
                        customIdentifier: customIdentifier)
    }
}
