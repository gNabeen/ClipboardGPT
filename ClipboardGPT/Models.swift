//
//  Models.swift
//  ClipboardGPT
//
//  Created by Nabin Gautam on 3/27/23.
//

import Foundation

struct Message: Codable {
    let role: String
    let content: String
}

struct GPTModel: Identifiable, Hashable {
    var id: Int
    var name: String
}


struct Response: Codable {
    let choices: [Choice]
    
    enum CodingKeys: String, CodingKey {
        case choices
    }
    
    struct Choice: Codable {
        let message: Message
        let finishReason: String
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: String
        
        enum CodingKeys: String, CodingKey {
            case role
            case content
        }
    }
}

