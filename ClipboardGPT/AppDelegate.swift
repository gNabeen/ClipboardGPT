//
//  AppDelegate.swift
//  ClipboardGPT
//
//  Created by Nabin Gautam on 3/27/23.
//

import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleAppHotkey = Self("toggleAppHotkey")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover = NSPopover()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPopover()
        setupStatusBarItem()
        setupEventListeners()
        registerHotKey()
    }
    
    private func setupPopover() {
        let contentView = ContentView()
        popover.contentSize = NSSize(width: 720, height: 240)
        popover.behavior = .transient
        popover.animates = false
        popover.contentViewController = NSHostingController(rootView: contentView)
    }
    
    private func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let image = NSImage(systemSymbolName: "doc.on.clipboard.fill", accessibilityDescription: nil)
        image?.resizingMode = .stretch
        image?.size = NSSize(width: image!.size.width * 3, height: image!.size.height * 3)
        statusBarItem.button?.image = image
    }
    
    private func setupEventListeners() {
        statusBarItem.button?.action = #selector(togglePopover(_:))
        statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusBarItem.button {
            let event = NSApp.currentEvent!
            switch event.type {
            case .leftMouseUp:
                handleLeftClick(button: button)
            case .rightMouseUp:
                handleRightClick(button: button)
            default:
                break
            }
        }
    }
    
    private func handleLeftClick(button: NSStatusBarButton) {
        print("left clicked")
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    private func handleRightClick(button: NSStatusBarButton) {
        print("right clicked")
        let menu = NSMenu()
//        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = menu
        statusBarItem.button?.performClick(nil)
        statusBarItem.menu = nil
    }
    
    func handleHotKeyToggle() {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    private func registerHotKey() {
        KeyboardShortcuts.onKeyUp(for: .toggleAppHotkey) { [weak self] in
            self?.handleHotKeyToggle()
        }
    }
}

