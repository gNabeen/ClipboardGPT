//
//  SettingsView.swift
//  ClipboardGPT
//
//  Created by Nabin Gautam on 3/27/23.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @Binding var apiKey: String
    @Binding var enableSafeWord: String
    @Binding var disableSafeWord: String
    @Binding var followSafeWord: String
    @Binding var unfollowSafeWord: String
    @Binding var isShowingSettings: Bool
    @Binding var formValidationFailed: Bool
    @Binding var apiError: Bool
    @Binding var apiErrorID: UUID
    @State private var isApiFocused = false
    @State private var isApiVisible = false
    @Binding var customPrompt: String
    @Binding var endPoint: String
    
    @Binding var selectedGPTModel: Int
    let gptModels: [GPTModel]
    
    func isSaved() -> Bool {
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
            UserDefaults.standard.set(enableSafeWord, forKey: "enableSafeWord")
            UserDefaults.standard.set(disableSafeWord, forKey: "disableSafeWord")
            UserDefaults.standard.set(followSafeWord, forKey: "followSafeWord")
            UserDefaults.standard.set(unfollowSafeWord, forKey: "unfollowSafeWord")
            UserDefaults.standard.set(selectedGPTModel, forKey: "selectedGPTModel")
            UserDefaults.standard.set(customPrompt, forKey: "customPrompt")
            UserDefaults.standard.set(endPoint, forKey: "endPoint")
            
            return false
        }
    
    var body: some View {
        GroupBox("More Settings") {
            VStack {
                TabView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("API Key")
                            .padding(.bottom, -19)
                        
                        HStack {
                            ZStack(alignment: .trailing) {
                                if isApiVisible {
                                    TextField("sk-xxxxxxxxxxxxxxxx", text: $apiKey, onCommit: {
                                        isApiFocused = false
                                    })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary).opacity(1))
                                } else {
                                    SecureField("sk-xxxxxxxxxxxxxxxx", text: $apiKey, onCommit: {
                                        isApiFocused = true
                                    })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary).opacity(1))
                                }
                                
                                Button(action: {
                                    isApiVisible.toggle()
                                }) {
                                    Image(systemName: isApiVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.blue)
                                        .padding(1)
                                }
                            }
                        }
                                        .background(apiError ? Color.red.opacity(0.2) : Color.clear)
                                        .onChange(of: apiKey) { _ in
                                            apiError = false
                                        }
                        
                        VStack(spacing: 25) {
                            HStack{
                                TextField("https://api.openai.com/v1/chat/completions", text: $endPoint)
                                    .cornerRadius(3)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary).opacity(1))
                                    .overlay(
                                        VStack {
                                            Text("Custom Endpoint")
                                                .padding(.top, -19)
                                        },
                                        alignment: .topLeading
                                    )
                                Picker(selection: $selectedGPTModel, label: Text("")) {
                                    ForEach(gptModels) { model in
                                        Text(model.name).tag(model.id)
                                    }
                                }.pickerStyle(MenuPickerStyle())
                                    .frame(width: 190)
                                    .overlay(
                                        VStack {
                                            Text("Model")
                                                .padding(.top, -19)
                                            Spacer()
                                        },
                                        alignment: .topLeading
                                    )
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary).opacity(1))
                                    .buttonStyle(.borderless)
                            }
                            TextEditor(text: $customPrompt)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .cornerRadius(3)
                                .frame(height: 50)
                                .padding(4)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary).opacity(1))
                                .overlay(
                                    VStack {
                                        Text("System Prompt")
                                            .padding(.top, -19)
                                    },
                                    alignment: .topLeading
                                )
                        }
                    }
                    .tabItem {
                        Label("API Details", systemImage: "gearshape")
                    }

                    VStack(alignment: .leading, spacing: 23) {
                        VStack {
                            Text("Safe Words")
                                .padding(.top, -17)

                            HStack {
                                Text("Enable")
                                    .font(.callout)
                                TextField("Enter an enable safe word", text: $enableSafeWord)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary).opacity(1))

                                Text("Disable")
                                    .font(.callout)
                                TextField("Enter a disable safe word", text: $disableSafeWord)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary).opacity(1))

                                Text("Follow")
                                    .font(.callout)
                                TextField("Enter a follow safe word", text: $followSafeWord)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary).opacity(1))

                                Text("unFollow")
                                    .font(.callout)
                                TextField("Enter a unfollow safe word", text: $unfollowSafeWord)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary).opacity(1))
                            }.padding(10)
                                .border(Color.red)
                                .overlay(
                                    VStack {
                                        Text("Safe Words")
                                            .padding(.top, -17)
                                    },
                                    alignment: .topLeading
                                )

                            HStack {
                                Text("Show/Hide")
                                    .font(.callout)

                                KeyboardShortcuts.Recorder(for: .toggleAppHotkey)
                                
                                    Text("Enable/Disable")
                                        .font(.callout)

                                    KeyboardShortcuts.Recorder(for: .toggleAssistant)
                                
                                        Text("Follow/Unfollow")
                                            .font(.callout)

                                        KeyboardShortcuts.Recorder(for: .toggleFollowUnfollow)
                                }
                            HStack {
                                   Text("Toggle Privacy Mode:")
                                       .font(.callout)

                                   KeyboardShortcuts.Recorder(for: .togglePrivacyModeHotkey)
                               }
                        }
                    }
                    .tabItem {
                        Label("Shortcuts", systemImage: "exclamationmark.shield")
                    }
                }
                
                HStack {
                    // Save and Cancel Buttons
                    Button(action: {
                        isShowingSettings = isSaved()
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }.buttonStyle(.borderless)
                    Button(action: {
                        isShowingSettings = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(10)
                    }.buttonStyle(.borderless)
                }
            }.frame(height: 313)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let gptModels: [GPTModel] = [
            GPTModel(id: 0, name: "gpt-3.5-turbo-0301"),
            GPTModel(id: 1, name: "gpt-3.5-turbo-0302"),
            GPTModel(id: 2, name: "gpt-3.5-turbo-0303")
        ]

        return SettingsView(
            apiKey: .constant(""),
            enableSafeWord: .constant("start"),
            disableSafeWord: .constant("stop"),
            followSafeWord: .constant("follow"),
            unfollowSafeWord: .constant("nofollow"),
            isShowingSettings: .constant(false),
            formValidationFailed: .constant(false),
            apiError: .constant(false),
            apiErrorID: .constant(UUID()),
            customPrompt: .constant("You are a helpful assistant."),
            endPoint: .constant("https://api.openai.com/v1/chat/completions"),
            selectedGPTModel: .constant(0),
            gptModels: gptModels
        )
    }
}

