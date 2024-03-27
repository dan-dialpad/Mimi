//
//  MessageHelper.swift
//  RudyExtension
//
//  Created by Dan Carlson on 2024-03-21.
//

import Foundation
import DataStore
import Intents

extension Message {
    var asINMessage: INMessage {
        let messageDate = ISO8601DateFormatter().date(from: date) ?? Date()
        return INMessage(
                identifier: id,
                conversationIdentifier: sender.id,
                content: content,
                dateSent: messageDate,
                sender: sender.asINPerson,
                recipients: [me.asINPerson],
                messageType: .text
            )
    }
}
