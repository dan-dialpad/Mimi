import Foundation

public struct Contact : Codable, Equatable, Hashable {
    public let id: String
    public let first: String
    public let last: String
    public let phone: String
    public let imageUrl: String

    public init(id: String, first: String, last: String, imageUrl: String, phone: String) {
        self.id = id
        self.first = first
        self.last = last
        self.imageUrl = imageUrl
        self.phone = phone
    }
}

public struct Message : Codable, Identifiable {
    public let id: String
    public let content: String
    public let date: String
    public let recipient: Contact
    public let sender: Contact
    public let unread: Bool

    public init(id: String, content: String, date: String, recipient: Contact, sender: Contact, unread: Bool) {
        self.id = id
        self.content = content
        self.date = date
        self.recipient = recipient
        self.sender = sender
        self.unread = unread
    }

    public func prettyTime() -> String {
        let messageDate = ISO8601DateFormatter().date(from: date) ?? Date()
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: messageDate)
    }
}

public struct Conversation: Codable, Identifiable {
    public let id: String
    public let contact: Contact
    public let lastMessage: Message
    public var isUnread:Bool { lastMessage.unread }

    public init(contact: Contact, lastMessage: Message) {
        self.id = contact.id
        self.contact = contact
        self.lastMessage = lastMessage
    }
}
