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
        if let urls = getURLList() {
            for url in urls {
                FileManager().unmountVolume(at: url, options: [.allPartitionsAndEjectDisk, .withoutUI], completionHandler: ejectionhandle)
            }
        }
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    let ejectionhandle: (Error?)->Void = {
        if ($0 == nil) {
            //print("Ejected: ")
        }else{
            //print("Failed to eject: ")
        }
    }
    
    func getURLList()->[URL]?{
        let keys: [URLResourceKey] = [.volumeNameKey,.volumeIsRemovableKey, .volumeIsEjectableKey]
        if var urls = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: []) {
            for url in urls{
                let components = url.pathComponents
                if components.count <= 1 || components[1] != "Volumes"{
                    urls.remove(at: urls.index(of: url)!)
                }
            }
            return urls;
        }
        else{
            return nil
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //statusItem.title = "EjectionSeat"
        statusItem.menu = statusMenu
        let icon = NSImage(named: NSImage.Name(rawValue: "ejectionseatIcon"))
        statusItem.image = icon
        statusItem.image?.isTemplate = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

