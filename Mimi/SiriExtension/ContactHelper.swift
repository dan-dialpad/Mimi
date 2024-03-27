//
//  ContactHelper.swift
//  RudyExtension
//
//  Created by Dan Carlson on 2024-03-21.
//

import Foundation
import DataStore
import Intents

extension Contact {
    var asINPerson: INPerson {
        let handle = INPersonHandle(value: phone, type: .phoneNumber)
        let nameComponents = PersonNameComponents(givenName: first, familyName: last)
        let displayName = "\(first) \(last)"
        let image = URL(string: imageUrl).flatMap { INImage(url: $0) }
        let customIdentifier = id
        let isMe = id == me.id
        return INPerson(personHandle: handle,
                        nameComponents: nameComponents,
                        displayName: displayName,
                        image: image,
                        contactIdentifier: nil,
                        customIdentifier: customIdentifier,
                        isMe: isMe)
    }
}
