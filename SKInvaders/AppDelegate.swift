//
//  AppDelegate.swift
//  SKInvaders
//
//  Created by Tom Elliott on 12/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//


import Cocoa
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            do {
                let sceneData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
                archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! SKNode
                archiver.finishDecoding()
                return scene
                
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
        if let scene = MenuScene.unarchiveFromFile("GameScene") as? MenuScene {
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            self.skView!.presentScene(scene)
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            self.skView!.ignoresSiblingOrder = true
            
            /*
            Use the below to display useful debug views
            
            self.skView!.showsPhysics = true
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true
            */
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }
}
