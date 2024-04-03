//
//  ContactsRegistrar.swift
//  Mimi
//
//  Created by Dan Carlson on 2024-04-01.
//

import Foundation
import DataStore
import Intents

struct ContactsRegistrar {

    static func registarContacts() {
        let speakableContacts: [INSpeakableString] = DataStore.contacts.map { $0.speakableContact() }
        let contacts = NSOrderedSet(array: speakableContacts)

        INVocabulary.shared().setVocabulary(contacts, of: .contactName)
    }
}

fileprivate extension Contact {
    func speakableContact() -> INSpeakableString {
        return INSpeakableString(vocabularyIdentifier: id,
                                 spokenPhrase: "\(first) \(last)",
                                 pronunciationHint: nil)
    }
}
