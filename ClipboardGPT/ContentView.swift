//
//  ContentView.swift
//  ClipboardGPT
//
//  Created by Nabin Gautam on 3/27/23.
//

import SwiftUI
import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleAssistant = Self("toggleAssistant")
    static let toggleFollowUnfollow = Self("toggleFollowUnfollow")
    static let togglePrivacyModeHotkey = Self("togglePrivacyModeHotkey")
}

class PrivacyState: ObservableObject {
    @Published var privacyModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(privacyModeEnabled, forKey: "PrivacyModeEnabled")
        }
    }

    init() {
        self.privacyModeEnabled = UserDefaults.standard.bool(forKey: "PrivacyModeEnabled")
    }
}
struct ContentView: View {
    @StateObject private var privacyState = PrivacyState()
    
    @State private var clipboardContent = ""
    @State private var lastApiResult = ""
    @State private var isLoading = false
    @State private var isEnabled = false
    @State private var timer: Timer?
    @State private var followsConversation = false
    @State private var conversationHistory: [Message] = []
    @State private var isShowingSettings = false
    @State private var apiKey = "sk-xxxxxxxxxxxxxxxx" // Your default API key here
    @State private var enableSafeWord = "start"
    @State private var disableSafeWord = "stop"
    @State private var followSafeWord = "follow"
    @State private var unfollowSafeWord = "nofollow"
    @State private var apiError = false
    @State private var formValidationFailed = false
    @State private var apiErrorID = UUID()
    @State private var ignoreClipboardUpdate = false
    @State private var selectedGPTModel = 0
    @State private var isHovered = false
    @State private var customPrompt = "you are a helpful assistant."
    @State private var endPoint = "https://api.openai.com/v1/chat/completions"
    
    private let gptModels: [GPTModel] = [
        GPTModel(id: 0, name: "gpt-3.5-turbo-0301"),
        GPTModel(id: 1, name: "gpt-3.5-turbo"),
        GPTModel(id: 2, name: "gpt-4")
    ]
    var enabledLabel: String {
        return isEnabled ? " Enabled" : "Disabled"
    }
    var followLabel: String {
        return followsConversation ? "Following" : "Follow up"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if privacyState.privacyModeEnabled {
                        privacyView
            } else {
                GroupBox(label: Text("Settings")) {
                    HStack {
                        Spacer()
                        Toggle(enabledLabel, isOn: $isEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .onChange(of: isEnabled) { value in
                                if value && (apiKey.isEmpty && endPoint.isEmpty) {
                                    formValidationFailed = true
                                    isShowingSettings = true
                                    isEnabled = false
                                } else {
                                    formValidationFailed = false
                                }
                            }
                        Spacer()
                        Toggle(followLabel, isOn: $followsConversation)
                            .toggleStyle(SwitchToggleStyle())
                        Button(action: {
                            conversationHistory = [] // Reset conversation history to empty array
                        }) {
                            Image(systemName: "trash.fill")
                        }
                        .background(Color.clear)
                        .help("Clear conversation history")
                        
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isShowingSettings.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.title)
                                    .rotationEffect(isShowingSettings ? Angle.degrees(90) : Angle.degrees(0))
                                    .cornerRadius(5)
                            }
                            .padding(5)
                            .background(isHovered ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(5)
                            .buttonStyle(.borderless)
                            .onHover { hovering in
                                isHovered = hovering
                            }
                        }
                        .buttonStyle(.borderless)
                        .help("More Settings")
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 44) // Add a fixed height of 44
                }.frame(height: 60)
                if isShowingSettings {
                    SettingsView(
                        apiKey: $apiKey,
                        enableSafeWord: $enableSafeWord,
                        disableSafeWord: $disableSafeWord,
                        followSafeWord: $followSafeWord,
                        unfollowSafeWord: $unfollowSafeWord,
                        isShowingSettings: $isShowingSettings,
                        formValidationFailed: $formValidationFailed,
                        apiError: $apiError,
                        apiErrorID: $apiErrorID,
                        customPrompt: $customPrompt,
                        endPoint: $endPoint,
                        selectedGPTModel: $selectedGPTModel,
                        gptModels: gptModels
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    GroupBox(label: Text("Clipboard")) {
                        HStack{
                            TextEditor(text: $clipboardContent)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .cornerRadius(3)
                                .frame(height:300)
                                .padding(4)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary).opacity(1))
                            Spacer()
                            TextEditor(text: $lastApiResult)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .cornerRadius(3)
                                .frame(height:300)
                                .padding(4)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary).opacity(1))
                        }
                    }.frame(height: 340)
                }
            }
        }
        .padding()
        .frame(width: 600, height: 450)
        .onAppear {
            KeyboardShortcuts.onKeyUp(for: .toggleFollowUnfollow) {
                self.toggleFollowUnfollow()
            }
            
            KeyboardShortcuts.onKeyUp(for: .toggleAssistant) {
                self.toggleAssistant()
            }
            
            KeyboardShortcuts.onKeyUp(for: .togglePrivacyModeHotkey) {
                    self.togglePrivacyMode()
                }
            
            if let savedApiKey = UserDefaults.standard.string(forKey: "apiKey") {
                apiKey = savedApiKey
            }
            if let savedEnableSafeWord = UserDefaults.standard.string(forKey: "enableSafeWord") {
                enableSafeWord = savedEnableSafeWord
            }
            if let savedDisableSafeWord = UserDefaults.standard.string(forKey: "disableSafeWord") {
                disableSafeWord = savedDisableSafeWord
            }
            if let savedFollowSafeWord = UserDefaults.standard.string(forKey: "followSafeWord") {
                followSafeWord = savedFollowSafeWord
            }
            if let savedUnfollowSafeWord = UserDefaults.standard.string(forKey: "unfollowSafeWord") {
                unfollowSafeWord = savedUnfollowSafeWord
            }
            if let savedSelectedGPTModel = UserDefaults.standard.object(forKey: "selectedGPTModel") as? Int {
                selectedGPTModel = savedSelectedGPTModel
            }
            if let savedCustomPrompt = UserDefaults.standard.string(forKey: "customPrompt") {
                customPrompt = savedCustomPrompt
            }
            if let savedEndPoint = UserDefaults.standard.string(forKey: "endPoint") {
                endPoint = savedEndPoint
            }
            
            self.clipboardContent = self.getCurrentClipboardContents()
            var previousClipboardContent = self.clipboardContent
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                let newClipboardContent = self.getCurrentClipboardContents()
                self.clipboardContent = newClipboardContent
                if newClipboardContent.lowercased() == disableSafeWord.lowercased() {
                    isEnabled = false
                    clipboardContent = "'\(disableSafeWord)' triggered disable shortcut."
                    previousClipboardContent = clipboardContent
                    return
                }
                if newClipboardContent.lowercased() == enableSafeWord.lowercased() {
                    isEnabled = true
                    clipboardContent = "'\(enableSafeWord)' triggered enable shortcut."
                    previousClipboardContent = clipboardContent
                    return
                }
                if newClipboardContent.lowercased() == followSafeWord.lowercased() {
                    followsConversation = true
                    clipboardContent = "'\(followSafeWord)' triggered follow shortcut."
                    previousClipboardContent = clipboardContent
                    return
                }
                if newClipboardContent.lowercased() == unfollowSafeWord.lowercased() {
                    followsConversation = false
                    clipboardContent = "'\(unfollowSafeWord)' triggered unfollow shortcut."
                    previousClipboardContent = clipboardContent
                    return
                }
                guard self.isEnabled && !self.isLoading else { return }
                if newClipboardContent.lowercased() != lastApiResult.lowercased() &&
                    newClipboardContent != previousClipboardContent {
                    self.sendToApi()
                    lastApiResult = "Loading..."
                    previousClipboardContent = newClipboardContent
                }
            }
        }
        .onDisappear{
            self.timer?.invalidate()
            KeyboardShortcuts.disable(.toggleAssistant)
        }
    }
    
    func getCurrentClipboardContents() -> String {
        guard let items = NSPasteboard.general.pasteboardItems else {
            return ""
        }
        
        for item in items {
            if let string = item.string(forType: .string) {
                return string
            }
        }
        
        return ""
    }
    
    func sendToApi() {
        isLoading = true
        
        let defaultURLString = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: endPoint.isEmpty ? defaultURLString : endPoint) else {
            print("Invalid URL: \(endPoint). Using the default: \(defaultURLString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !followsConversation {
            conversationHistory = []
        }
        
        if !customPrompt.isEmpty && conversationHistory.isEmpty {
            conversationHistory.append(Message(role: "system", content: customPrompt))
        }
        
        var newMessage = Message(role: "user", content: clipboardContent)
        conversationHistory.append(newMessage)
        
        let body: [String: Any] = [
            "model": gptModels[selectedGPTModel].name,
            "messages": conversationHistory.map { message in
                return [
                    "role": message.role,
                    "content": message.content
                ]
            }
        ]
        print(body)
        print("using \(gptModels[selectedGPTModel].name)")
        let jsonData = try! JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        var task: URLSessionDataTask? = nil
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false
            guard let data = data, error == nil else {
                print("Error: \(error!)")
                task?.cancel() // Cancel the task on error
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseJSON = try decoder.decode(Response.self, from: data)
                let responseText = responseJSON.choices[0].message.content
                
                if responseText != self.lastApiResult {
                    newMessage = Message(role: "assistant", content: responseText)
                    conversationHistory.append(newMessage)
                    self.lastApiResult = responseText
                    ignoreClipboardUpdate = true
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(responseText, forType: .string)
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                task?.cancel() // Cancel the task on decoding error
                DispatchQueue.main.async {
                    self.apiError = true
                    self.apiErrorID = UUID()
                    self.isShowingSettings = true
                }
            }
        }
        task?.resume()
    }
    
    func toggleAssistant() {
        self.isEnabled.toggle()
    }
    
    func toggleFollowUnfollow() {
        followsConversation.toggle()
    }
    
    func togglePrivacyMode() {
        privacyState.privacyModeEnabled.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private var privacyView: some View {
    PrivacyView()
}


