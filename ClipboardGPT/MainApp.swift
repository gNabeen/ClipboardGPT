//
//  Menu.swift
//  ClipboardGPT
//
//  Created by Nabin Gautam on 3/27/23.
//

import SwiftUI

@main
struct MainApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
