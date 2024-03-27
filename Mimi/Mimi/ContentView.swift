//
//  ContentView.swift
//  Mimi
//
//  Created by Dan Carlson on 2024-03-01.
//

import DataStore
import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Conversations")
            List {
                ForEach(conversations) { conversation in
                    conversationSummary(conversation)
                }
            }
        }
    }

    @ViewBuilder
    func conversationSummary(_ conversation: Conversation) -> some View {
        HStack {
            AsyncImage(url: URL(string: conversation.contact.imageUrl)).frame(width: 60, height: 60).clipShape(Circle())
            VStack(alignment: .leading, content: {
                Text(conversation.lastMessage.content).bold(conversation.isUnread)
                Text(conversation.lastMessage.prettyTime()).font(.callout).foregroundColor(.gray)
            })
            if conversation.isUnread {
                Spacer()
                Circle().frame(width: 15, height: 15).foregroundColor(.blue)
            }
        }
    }
}
