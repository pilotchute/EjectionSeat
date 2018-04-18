//
//  AppDelegate.swift
//  EjectionSeat
//
//  Created by Austin Kootz on 4/17/18.
//  Copyright © 2018 Austin Kootz. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var menu: NSMenu = NSMenu()
    
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
        var numKey = 0
        for url in urls {
        numKey += 1
            subMenu.addItem(NSMenuItem(title: url.pathComponents[url.pathComponents.endIndex-1], action: #selector(AppDelegate.eject(_:)), keyEquivalent: "\(numKey)"))
        }
        return subMenu
    }
    
    @objc func eject(_ sender: NSMenuItem){
        print(sender.title)
        guard let urls = getURLList(), urls.count > 0 else {
            return
        }
        for url in urls {
            if url.pathComponents[url.pathComponents.endIndex-1] == sender.title {
                FileManager().unmountVolume(at: url, options: [.allPartitionsAndEjectDisk, .withoutUI], completionHandler: ejectionhandle)
            }
        }
    }
    
    @objc func ejectAll(_ sender: NSMenuItem) {
        guard let urls = getURLList(), urls.count > 0 else {
            return
        }
        for url in urls {
            FileManager().unmountVolume(at: url, options: [.allPartitionsAndEjectDisk, .withoutUI], completionHandler: ejectionhandle)
        }
    }
    
    @objc func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    let ejectionhandle: (Error?)->Void = {
        if ($0 == nil) {
            //print("Ejected: ")
        }else{
            //print("Eject Failed: ")
        }
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
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    
}

