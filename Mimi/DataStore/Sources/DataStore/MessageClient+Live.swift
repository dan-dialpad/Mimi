//
//  MessageClient+Live.swift
//
//
//  Created by Dan Carlson on 2024-03-08.
//

import Foundation

public extension MessageClient {

    static let me = DataStore.bob

    public static let live = Self(markContactMessagesAsRead: { contact in
        liveMessages.indices.filter {
            liveMessages[$0].recipient == contact || liveMessages[$0].sender == contact
        }.forEach {
            let oldMessage = liveMessages[$0]
            let newMessage = Message(id: oldMessage.id,
                                     content: oldMessage.content,
                                     date: oldMessage.date,
                                     recipient: oldMessage.recipient,
                                     sender: oldMessage.sender,
                                     unread: false)
            liveMessages[$0] = newMessage
        }
    }, markMessageAsRead: { messageId in
        liveMessages.indices.filter {
            liveMessages[$0].id == messageId
        }.forEach {
            let oldMessage = liveMessages[$0]
            let newMessage = Message(id: oldMessage.id,
                                     content: oldMessage.content,
                                     date: oldMessage.date,
                                     recipient: oldMessage.recipient,
                                     sender: oldMessage.sender,
                                     unread: false)
            liveMessages[$0] = newMessage
        }
    }, sendMessage: { content, contact in
        let id = "\(liveMessages.count)"
        let message = Message(id: id,
                              content: content,
                              date: ISO8601DateFormatter().string(from: Date()),
                              recipient: contact,
                              sender: me,
                              unread: false)
        liveMessages.append(message)
        return true
    }, unreadMessages: {
        liveMessages.filter { message in
            return message.unread && message.recipient == me
        }
    }, unreadMessagesFromContact: { contact in
        liveMessages.filter { message in
            return message.unread && message.recipient == me && message.sender == contact
        }
    })
}
