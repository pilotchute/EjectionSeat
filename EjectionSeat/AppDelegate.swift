//
//  AppDelegate.swift
//  EjectionSeat
//
//  Created by Austin Kootz on 4/17/18.
//  Copyright © 2018 Austin Kootz. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSUserNotificationCenterDelegate, NSWindowDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu: NSMenu = NSMenu()
    var aboutWindow: NSWindow?
    var lastVolume: String = ""
    let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    func delay(_ seconds: Int, block: @escaping () -> Void){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: block)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //statusItem.title = "EjectionSeat"
        statusItem.image = NSImage(named: NSImage.Name("USBIcon"))
        statusItem.image?.isTemplate = true
        statusItem.menu = menu
        statusItem.menu?.delegate = self
        makeAboutWindow()
    }
    
    func makeMenu() {
        menu.removeAllItems()
        if let subMenu = makeSubMenu() {
            menu.addItem(NSMenuItem(title: "Eject All", action: #selector(AppDelegate.ejectAll(_:)), keyEquivalent: "e"))
            menu.addItem(NSMenuItem(title: "Eject", action: nil, keyEquivalent: ""))
            menu.setSubmenu(subMenu, for: (menu.item(withTitle: "Eject"))!)
        } else {
            menu.addItem(NSMenuItem(title: "Nothing to eject", action: nil, keyEquivalent: ""))
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About", action: #selector(AppDelegate.aboutWindowDisplay(_:)), keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "q"))
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        makeMenu()
    }
    
    func makeAboutWindow(){
        let aboutView = NSView(frame: NSMakeRect(0, 0, 192, 256))
        let aboutImage = NSImageView(image: NSImage(named: NSImage.Name("AppIcon"))!)
        let aboutTextTitle = NSTextView(frame: NSMakeRect(0, 0, 192, 16))
        let aboutTextBody = NSTextView(frame: NSMakeRect(0, 0, 192, 12))
        
        aboutView.addSubview(aboutImage)
        aboutView.addSubview(aboutTextTitle)
        aboutView.addSubview(aboutTextBody)
        
        aboutImage.setFrameSize(NSSize(width: 192, height: 128))
        aboutImage.setFrameOrigin(NSPoint(x:0,y:96))
        aboutImage.imageAlignment = NSImageAlignment.alignCenter
        
        aboutTextTitle.setFrameOrigin(NSPoint(x:0,y:64))
        aboutTextTitle.font = NSFont.titleBarFont(ofSize: 16)
        aboutTextTitle.textColor = NSColor.textColor
        aboutTextTitle.alignment = NSTextAlignment.center
        aboutTextTitle.backgroundColor = NSColor.clear
        aboutTextTitle.insertText("EjectionSeat.app")
        aboutTextTitle.isEditable = false
        
        aboutTextBody.setFrameOrigin(NSPoint(x:0,y:40))
        aboutTextBody.font = NSFont.systemFont(ofSize: 12)
        aboutTextBody.textColor = NSColor.gray
        aboutTextBody.alignment = NSTextAlignment.center
        aboutTextBody.backgroundColor = NSColor.clear
        aboutTextBody.insertText("Developed by Åustin Kootz\nVersion \(version)")
        aboutTextBody.isEditable = false
        
        aboutWindow = NSWindow.init(contentRect: aboutView.frame, styleMask: [.titled, .closable], backing: NSWindow.BackingStoreType.buffered, defer:false)
        aboutWindow?.contentView = aboutView
        aboutWindow?.backgroundColor = NSColor.windowBackgroundColor
        aboutWindow?.isReleasedWhenClosed = false
        aboutWindow?.title = "About EjectionSeat"
    }
    
    @objc func aboutWindowDisplay(_ sender:NSMenuItem) {
        aboutWindow?.cascadeTopLeft(from: NSEvent.mouseLocation)
        aboutWindow?.orderFrontRegardless()
    }
    
    @objc func makeSubMenu() -> NSMenu? {
        guard let urls = getURLList(), urls.count > 0 else { return nil }
        let subMenu = NSMenu()
        var titles: [String] = []
        for url in urls {
            titles.append(url.pathComponents[url.pathComponents.endIndex-1])
        }
        titles = titles.sorted{$0.caseInsensitiveCompare($1) == .orderedAscending}
        var numKey = 0
        for title in titles {
            numKey += 1
            subMenu.addItem(NSMenuItem(title: title, action: #selector(AppDelegate.eject(_:)), keyEquivalent: "\(numKey)"))
        }
        return subMenu
    }
    
    @objc func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func eject(_ sender: NSMenuItem) {
        guard let urls = getURLList(), urls.count > 0 else { return }
        for url in urls {
            if url.pathComponents[url.pathComponents.endIndex-1] == sender.title {
                lastVolume = sender.title
                guard (try? NSWorkspace().unmountAndEjectDevice(at: url)) != nil else {
                    showNotificationFailure()
                    return
                }
                showNotificationSuccess()
            }
        }
    }
    
    @objc func ejectAll(_ sender: NSMenuItem) {
        var hideError = true
        var keepGoing = true
        while keepGoing {
            var anySuccess = false
            guard let urls = getURLList(), urls.count > 0 else { return }
            for url in urls {
                lastVolume = url.pathComponents[url.pathComponents.endIndex-1]
                guard (try? NSWorkspace().unmountAndEjectDevice(at: url)) != nil else {
                    if !hideError {
                        showNotificationFailure()
                    }
                    continue
                }
                showNotificationSuccess()
                anySuccess = true
            }
            keepGoing = hideError
            hideError = anySuccess
        }
    }
    
    func showNotificationSuccess() {
        let notification = NSUserNotification()
        notification.identifier = "Success \(lastVolume)"
        notification.title = "\(lastVolume)"
        notification.informativeText = "Ejected safely!"
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = false
        notification.otherButtonTitle = "Dismiss"
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func showNotificationFailure() {
        let notification = NSUserNotification()
        notification.identifier = "Failure \(lastVolume)"
        notification.title = "\(lastVolume)"
        notification.informativeText = "Failed to eject."
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = true
        notification.otherButtonTitle = "Dismiss"
        notification.actionButtonTitle = "Eject"
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        notification.hasActionButton ?
            delay(60){NSUserNotificationCenter.default.removeDeliveredNotification(notification)} :
            delay(3){NSUserNotificationCenter.default.removeDeliveredNotification(notification)}
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        eject(NSMenuItem(title: notification.title!, action: nil, keyEquivalent: ""))
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func getURLList()->[URL]? {
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey, .volumeIsEjectableKey]
        guard var urls = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: []) else {
            return nil
        }
        for url in urls {
            let components = url.pathComponents
            if components.count < 2 || components[1] != "Volumes"{
                urls.remove(at: urls.index(of: url)!)
            }
        }
        return urls;
    }
}

