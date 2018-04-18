//
//  AppDelegate.swift
//  EjectionSeat
//
//  Created by Austin Kootz on 4/17/18.
//  Copyright © 2018 Austin Kootz. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBAction func ejectAll(_ sender: Any) {
        guard let urls = getURLList(), urls.count > 0 else {
            return
        }
        for url in urls {
            FileManager().unmountVolume(at: url, options: [.allPartitionsAndEjectDisk, .withoutUI], completionHandler: ejectionhandle)
        }
    }
    
    
    @IBAction func quit(_ sender: Any) {
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
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //statusItem.title = "EjectionSeat"
        statusItem.menu = statusMenu
        let icon = NSImage(named: NSImage.Name(rawValue: "USBIcon"))
        statusItem.image = icon
        statusItem.image?.isTemplate = true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    
}

