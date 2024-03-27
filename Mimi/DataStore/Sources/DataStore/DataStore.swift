// The Swift Programming Language
// https://docs.swift.org/swift-book
@_exported import Models
import Foundation

//Global live data - not shared between app ex and app yet
public var liveMessages:[Message] = DataStore.messages
public var liveContacts:[Contact] = DataStore.contacts
public let me: Contact = DataStore.bob
public var conversations: [Conversation] {
    let messagesLastToFirst = liveMessages.sorted { $0.id > $1.id }
    let contactsWithMessages:[Contact] = messagesLastToFirst.compactMap { message in
        if message.recipient != me { return message.recipient }
        if message.sender != me { return message.sender }
        return nil
    }
    let distinctContactsWithMessages = Array(Set(contactsWithMessages))
    let conversations = distinctContactsWithMessages.flatMap { contact in
        let lastMessage = messagesLastToFirst.first { message in
            message.recipient == contact || message.sender == contact
        }
        return lastMessage.flatMap { Conversation(contact: contact, lastMessage: $0) }
    }
    return conversations.sorted { $0.lastMessage.id < $1.lastMessage.id }
}

public struct DataStore {

    public static let contacts: [Contact] = [Contact(id: "0", first: "Anna", last: "Graham", imageUrl: "https://picsum.photos/seed/user_0/100/100", phone: "226-555-0000"),
                              Contact(id: "1", first: "Bob", last: "Zuruncle", imageUrl: "https://picsum.photos/seed/user_1/100/100", phone: "226-555-0001"),
                              Contact(id: "2", first: "Charlie", last: "Hustle", imageUrl: "https://picsum.photos/seed/user_2/100/100", phone: "226-555-0002"),
                             Contact(id: "3", first: "Dan", last: "Jerous", imageUrl: "https://picsum.photos/seed/user_3/100/100", phone: "226-555-0003")]

    public static let anna: Contact = contacts[0]
    public static let bob: Contact = contacts[1]
    public static let charlie: Contact = contacts[2]
    public static let dan: Contact = contacts[3]

    public static let messages: [Message] = [Message(id: "0", content: "Hi Anna", date: dateOffsetToString(800), recipient: bob, sender: anna, unread: false),
                                             Message(id: "1", content:  "Hi Bob, what's for supper", date: dateOffsetToString(700), recipient: anna, sender: bob, unread: false),
                                             Message(id: "2", content: "Hrm. Not sure, let me check.", date: dateOffsetToString(600), recipient: anna, sender: bob, unread: false),
                                             Message(id: "3", content: "Can we have tacos?", date: dateOffsetToString(500), recipient: bob, sender: anna, unread: true),
                                             Message(id: "4", content: "Yo Bob, what book are we reading for book club this month?", date: dateOffsetToString(400), recipient: bob, sender: charlie, unread: true),
                                             Message(id: "5", content: "The Will of the Many?", date: dateOffsetToString(300), recipient: bob, sender: charlie, unread: true),
                                             Message(id: "6", content: "Those tacos were SOOO good.", date: dateOffsetToString(200), recipient: bob, sender: dan, unread: false),
                                             Message(id: "7", content: "YAAASS! 🌮🤘🚀", date: dateOffsetToString(100), recipient: dan, sender: bob, unread: false)]

    static let formatter = ISO8601DateFormatter()
    private static func dateOffsetToString(_ offset: TimeInterval) -> String {
        return formatter.string(from: Date().addingTimeInterval(offset * -1))
    }
}

public struct MessageClient {
    public var markContactMessagesAsRead: (Contact) async throws -> Void = { _ in }
    public var markMessageAsRead: (String) async throws -> Void = { _ in }
    public var sendMessage: (String, Contact) async throws -> Bool  = { _, _ in false }
    public var unreadMessages: () async throws -> [Message] = { [] }
    public var unreadMessagesFromContact: (Contact) async throws -> [Message] = { _ in [] }
}

public struct ContactClient {
    public var contactwithID:(String) async throws -> Contact? = { _ in nil }
    public var contactsMatchingName:(String?, String?) async throws -> [Contact] = { _, _ in [] }
}
