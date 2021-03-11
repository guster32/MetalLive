//
//  AppDelegate.swift
//  MetalLive
//
//  Created by Gustavo Branco on 3/10/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  @IBAction func new(_ sender: Any) {
    let mlWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "WindowController") as! NSWindowController
    mlWindowController.showWindow(self)
  }
}

