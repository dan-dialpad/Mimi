//
//  IntentHandler.swift
//  RudyExtension
//
//  Created by Dan Carlson on 2024-03-01.
//

import Intents
import DataStore

class IntentHandler: INExtension, INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling {

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        print("\n***START\n\(Date().timeIntervalSince1970)\n\(String(describing:intent))\n***END")
        return self
    }

    // MARK: - INSendMessageIntentHandling

    func resolveRecipients(for intent: INSendMessageIntent) async -> [INSendMessageRecipientResolutionResult] {
        var conversationIdentifiers: [String] = []
        if let conversationIdentifier = intent.conversationIdentifier {
            conversationIdentifiers = [conversationIdentifier]
        }
        let inPersonsFound = await resolveRecipients(for: intent.recipients, conversationIdentifiers: conversationIdentifiers)

        var resolutionResults = [INSendMessageRecipientResolutionResult]()
        switch inPersonsFound.count {
        case 2  ... Int.max:
            // We need Siri's help to ask user to pick one from the matches.
            resolutionResults += [INSendMessageRecipientResolutionResult.disambiguation(with: inPersonsFound)]
        case 1:
            // We have exactly one matching contact
            guard let person = inPersonsFound.first else { break }
            resolutionResults += [INSendMessageRecipientResolutionResult.success(with: person)]
        case 0:
            resolutionResults += [INSendMessageRecipientResolutionResult.unsupported()]

        default:
            resolutionResults += [INSendMessageRecipientResolutionResult.unsupported()]
        }
        return resolutionResults
    }

//    func resolveRecipients(for intent: INSearchForMessagesIntent) async -> [INPersonResolutionResult] {
//        let inPersonsFound = await resolveRecipients(for: intent.recipients, conversationIdentifiers: intent.conversationIdentifiers)
//        
//        var resolutionResults = [INPersonResolutionResult]()
//        switch inPersonsFound.count {
//        case 2  ... Int.max:
//            // We need Siri's help to ask user to pick one from the matches.
//            resolutionResults += [INPersonResolutionResult.disambiguation(with: inPersonsFound)]
//        case 1:
//            // We have exactly one matching contact
//            guard let person = inPersonsFound.first else { break }
//            resolutionResults += [INPersonResolutionResult.success(with: person)]
//        case 0:
//            resolutionResults += [INPersonResolutionResult.unsupported()]
//
//        default:
//            resolutionResults += [INPersonResolutionResult.unsupported()]
//        }
//        return resolutionResults
//    }

    private func resolveRecipients(for recipients: [INPerson]?, conversationIdentifiers: [String]?) async -> [INPerson] {

        if let conversationIdentifier = conversationIdentifiers?.first {
            do {
                if let foundContact = try await ContactClient.live.contactwithID(conversationIdentifier) {
                    return [foundContact.asINPerson]
                }
            } catch { }
        }

        guard let recipients = recipients, recipients.count > 0 else {
            return []
        }


        do
        {
            for recipient in recipients {
                var appContacts: [Contact] = []
                if let customIdentifier = recipient.customIdentifier {
                    do {
                        if let foundContact = try await ContactClient.live.contactwithID(customIdentifier) {
                            appContacts.append(foundContact)
                        }
                    } catch {
                        print("failed to find app contact from id \(customIdentifier)")
                    }
                    // lookup with name components of sender
                } else {
                    let firstName = recipient.nameComponents?.givenName
                    let lastName = recipient.nameComponents?.familyName
                    let foundContacts = try await ContactClient.live.contactsMatchingName(firstName, lastName)
                    appContacts = foundContacts
                }
                guard appContacts.count > 0 else {
                    return []
                }
                let matchingContacts = appContacts.compactMap { $0.asINPerson }
                return matchingContacts
            }
        } catch { }
        return []
    }

    func resolveContent(for intent: INSendMessageIntent) async -> INStringResolutionResult {
        


        if let text = intent.content, !text.isEmpty {
            return INStringResolutionResult.success(with: text)
        } else {
            return INStringResolutionResult.needsValue()
        }
    }

    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    func confirm(intent: INSendMessageIntent) async -> INSendMessageIntentResponse {
        // Verify user is authenticated and your app is ready to send a message.
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        return INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
    }

    // Handle the completed intent (required).
    func handle(intent: INSendMessageIntent) async -> INSendMessageIntentResponse {

        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let content = intent.content
        guard let content = content else {
            print("INSendMessageIntent failed due to no content")
            return INSendMessageIntentResponse(code: .failure, userActivity: userActivity)
        }

        // we only support one recipient
        guard let recipient = intent.recipients?.first else {
            print("INSendMessageIntent failed due to no recipient")
            return INSendMessageIntentResponse(code: .failure, userActivity: userActivity)
        }

        //isolate contact
        var contact: Contact?
        do {
            contact = try await fetchContactFromPerson(person: recipient)
        } catch { }
        guard let contact = contact else {
            print("INSendMessageIntent failed due to no contact being isolated")
            return INSendMessageIntentResponse(code: .failure, userActivity: userActivity)
        }

        do {
            _ = try await MessageClient.live.sendMessage(content, contact)
            return INSendMessageIntentResponse(code: .success, userActivity: userActivity)
        } catch {
            print("INSendMessageIntent failed failed to MessageClient error")
        }
        return INSendMessageIntentResponse(code: .failure, userActivity: userActivity)
    }

    // Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.

    // MARK: - INSearchForMessagesIntentHandling
    func handle(intent: INSearchForMessagesIntent) async -> INSearchForMessagesIntentResponse {

//        print("INSearchForMessagesIntent")
        // Implement your application logic to find a message that matches the information in the intent.
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
        let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)

        // we only support messages with one explicit sender for simplicity
        if let senders = intent.senders, senders.count == 1, let sender = senders.first {
            do {
                let messages = try await fetchSingleSenderUnreadMessages(sender: sender)
                response.messages = messages
                return response
            } catch {
                return INSearchForMessagesIntentResponse(code: .failure, userActivity: userActivity)
            }
        // if no recipient or more than one recipient, return all unreads
        } else {
            do {
                let messages = try await MessageClient.live.unreadMessages().map { $0.asINMessage }
                response.messages = messages
                return response
            } catch {
                return INSearchForMessagesIntentResponse(code: .failure, userActivity: userActivity)
            }
        }
    }

    // MARK: - INSetMessageAttributeIntentHandling
    func handle(intent: INSetMessageAttributeIntent) async -> INSetMessageAttributeIntentResponse {

        print("INSetMessageAttributeIntent: \(intent)")
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))

        guard intent.attribute == .read, let messageId = intent.identifier else {
            return INSetMessageAttributeIntentResponse(code: .failureMessageAttributeNotSet, userActivity: userActivity)
        }
        do {
            try await MessageClient.live.markMessageAsRead(messageId)
        } catch {
            print("failed to mark message \(messageId) as read")
            return INSetMessageAttributeIntentResponse(code: .failure, userActivity: userActivity)
        }

        return INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
    }

    // fetch contact from an INPerson
    private func fetchContactFromPerson(person: INPerson) async throws -> Contact {
        var appContact: Contact?
        // lookup with our apps custom identifier
        if let customIdentifier = person.customIdentifier {
            do {
                if let foundContact = try await ContactClient.live.contactwithID(customIdentifier) {
                    appContact = foundContact
                }
            } catch {
                print("failed to find app contact from id \(customIdentifier)")
            }
            // lookup with name components of sender
        } else {
            let firstName = person.nameComponents?.givenName
            let lastName = person.nameComponents?.familyName
            let foundContacts = try await ContactClient.live.contactsMatchingName(firstName, lastName)
            if let firstContact = foundContacts.first {
                appContact = firstContact
            }
        }
        // if no contact found, return failure
        guard let appContact = appContact else {
            throw RudyError.NoContactFound
        }
        return appContact
    }

    // fetch unreads from a single sender
    private func fetchSingleSenderUnreadMessages(sender: INPerson) async throws -> [INMessage] {
        let appContact = try await fetchContactFromPerson(person: sender)
        return try await MessageClient.live.unreadMessagesFromContact(appContact).map { $0.asINMessage }
    }

    enum RudyError: Error {
        case NoContactFound
    }

}
