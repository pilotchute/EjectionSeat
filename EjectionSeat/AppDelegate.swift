//
//  AppDelegate.swift
//  EjectionSeat
//
//  Created by Austin Kootz on 4/17/18.
//  Copyright © 2018 Austin Kootz. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSUserNotificationCenterDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu: NSMenu = NSMenu()
    var noteCounter: Int = 0
    var attemptCounter: Int = 0
    var lastDrive: String = ""
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //statusItem.title = "EjectionSeat"
        let icon = NSImage(named: NSImage.Name("USBIcon"))
        statusItem.image = icon
        statusItem.image?.isTemplate = true
        statusItem.menu = menu
        statusItem.menu?.delegate = self
        makeMenu()
    }
    
    func makeMenu(){
        menu.removeAllItems()
        menu.addItem(NSMenuItem(title: "Eject All", action: #selector(AppDelegate.ejectAll(_:)), keyEquivalent: "e"))
        menu.addItem(NSMenuItem(title: "Eject", action: nil, keyEquivalent: ""))
        menu.setSubmenu(makeSubMenu(), for: (menu.item(withTitle: "Eject"))!)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "q"))
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        makeMenu()
    }
    
    @objc func makeSubMenu() -> NSMenu?{
        guard let urls = getURLList(), urls.count > 0 else {
            return nil
        }
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
    
    @objc func eject(_ sender: NSMenuItem){
        guard let urls = getURLList(), urls.count > 0 else {
            return
        }
        for url in urls {
            if url.pathComponents[url.pathComponents.endIndex-1] == sender.title {
                lastDrive = sender.title
                FileManager().unmountVolume(at: url, options: [.allPartitionsAndEjectDisk, .withoutUI], completionHandler: ejectionhandle)
            }
        }
    }
    
    func ejectString(_ name: String){
        guard let urls = getURLList(), urls.count > 0 else {
            return
        }
        for url in urls {
            if url.pathComponents[url.pathComponents.endIndex-1] == name {
                lastDrive = name
                FileManager().unmountVolume(at: url, options: [.allPartitionsAndEjectDisk, .withoutUI], completionHandler: ejectionhandle)
            }
        }
    }
    
    @objc func ejectAll(_ sender: NSMenuItem) {
        guard let urls = getURLList(), urls.count > 0 else {
            return
        }
        
        for url in urls {
            lastDrive = url.pathComponents[url.pathComponents.endIndex-1]
            FileManager().unmountVolume(at: url, options: [.allPartitionsAndEjectDisk, .withoutUI], completionHandler: ejectionhandle)
        }
        
    }
    
    @objc func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    func ejectionhandle(_ error: Error?) {
        guard let errorData: Error = error else {
            showNotificationSuccess("Eject Successful!", "Your drive “\(lastDrive)” is safe.")
            return
        }
        showNotificationFailure("Eject Error", errorData.localizedDescription)
    }
    
    func showNotificationSuccess(_ title: String, _ text: String) {
        noteCounter += 1
        let notification = NSUserNotification()
        notification.identifier = "Notification \(noteCounter)"
        notification.title = title
        notification.informativeText = text
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = false
        notification.otherButtonTitle = "Dismiss"
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func showNotificationFailure(_ title: String, _ text: String) {
        noteCounter += 1
        let notification = NSUserNotification()
        notification.identifier = "Notification \(noteCounter)"
        notification.title = title
        notification.informativeText = text
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = true
        notification.otherButtonTitle = "Dismiss"
        notification.actionButtonTitle = "Eject"
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification){
        let name: String = ((notification.informativeText?.components(separatedBy: "“")[1])?.components(separatedBy: "”")[0])!
        ejectString(name)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func getURLList()->[URL]?{
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey, .volumeIsEjectableKey]
        guard var urls = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: []) else {
            return nil
        }
        for url in urls{
            let components = url.pathComponents
            if components.count <= 1 || components[1] != "Volumes"{
                urls.remove(at: urls.index(of: url)!)
            }
        }
        return urls;
    }
}

