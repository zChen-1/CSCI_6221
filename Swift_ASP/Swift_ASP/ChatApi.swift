
//
//  ChatApi.swift
//  Swift_ASP
//
//  Created by chou on 2024/11/19.
import StreamChat
import StreamChatSwiftUI
import Foundation
import SwiftUI

final class ChatApi {
    static let shared = ChatApi()
    
    var chatClient: ChatClient = {
        var config = ChatClientConfig(apiKey: .init("xtwrznnyx6tk"))
        config.isLocalStorageEnabled = true
        let client = ChatClient(config: config)
        return client
    }()
    
    @State var streamChat: StreamChat?
    
    public init() {
        streamChat = StreamChat(chatClient: chatClient)
        connectUser()
    }
    
    public func connectUser() {
        
        if let token = generateToken(userId: "g123456789") {
           
            chatClient.connectUser(
                userInfo: .init(
                    id: "g123456789",
                    name: "1349131",
                    imageURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")!
                ),
                token: token
            ) { error in
                if let error = error {
                    log.error("Connecting user failed: \(error)")
                } else {
                    log.info("User connected successfully")
                }
            }
        } else {
            log.error("Token generation failed.")
        }
    }
    func generateToken(userId: String) -> Token? {
        do {
            let token = try Token(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZzEyMzQ1Njc4OSJ9.lUJpQ_YkJn4dERZlFm2QdIXkefRy75o-fTzFhebscmA")
            _ = token.rawValue
            return token
        } catch {
            log.error("Error creating token: \(error)")
            return nil
        }
    }
}
