//
//  StatusMenuController.swift
//  ibreaktime
//
//  Created by oleg on 06.04.16.
//  Copyright © 2016 Oleg Orlov. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {
	@IBOutlet weak var statusMenu: NSMenu!
	
	var preferencesWindow: PreferencesWindow!
	var aboutWindow: AboutWindow!
	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
	let defaults = NSUserDefaults.standardUserDefaults()
	var bt: Breaktimer!
	var showSeconds = false
	
	@IBAction func quitClicked(sender: AnyObject) {
		NSApplication.sharedApplication().terminate(self)
	}
	
	@IBAction func preferencesClicked(sender: AnyObject) {
		preferencesWindow.showWindow(nil)
		NSApp.activateIgnoringOtherApps(true)
	}
	
	@IBOutlet weak var cyclesMenuItem: NSMenuItem!
	
	@IBAction func cyclesClicked(sender: AnyObject) {
		bt.cyclesCount = 0
		defaults.setValue(0, forKey: "cyclesCount")
		showStatus()
	}
	
	@IBAction func aboutClicked(sender: AnyObject) {
		aboutWindow.showWindow(nil)
		NSApp.activateIgnoringOtherApps(true)
	}
	
	@IBAction func resetTimerClicked(sender: AnyObject) {
		bt.resetTimer()
		showStatus()
	}
	
	func showStatus() {
		var timeString: String
		
		defaults.setValue(bt.cyclesCount, forKey: "cyclesCount")
		defaults.setValue(bt.lastCheckTime, forKey: "lastCheckTime")
		
		if bt.leftTime > 0 {
			if showSeconds {
				timeString = String(format: "%d:%02d", bt.leftTime/60, bt.leftTime%60)
			} else {
				timeString = String(lroundf(Float(bt.leftTime)/60))
			}
			
			if bt.timeToWork {
				statusItem.title = timeString
			} else {
				statusItem.title = "Rest: \(timeString)"
			}
		} else {
			if bt.timeToWork {
				statusItem.title = "Time to Rest"
			}
		}
		
		cyclesMenuItem.title = "Cycles: \(bt.cyclesCount)"
	}
	
	func showSecondsCheckboxClicked(showSeconds: Bool) {
		self.showSeconds = showSeconds
		showStatus()
	}
	
	func loadPreferences() {
		bt.workInterval = defaults.integerForKey("workInterval")
		bt.breakInterval = defaults.integerForKey("breakInterval")
		bt.idleTimer.maxIdleInterval = defaults.integerForKey("maxIdleInterval")
		bt.cyclesResetIdleInterval = defaults.integerForKey("cyclesResetIdleInterval")
	}
	
	func savePreferences() {
		defaults.setValue(bt.workInterval, forKey: "workInterval")
		defaults.setValue(bt.breakInterval, forKey: "breakInterval")
		defaults.setValue(bt.idleTimer.maxIdleInterval, forKey: "maxIdleInterval")
		defaults.setValue(bt.cyclesResetIdleInterval, forKey: "cyclesResetIdleInterval")
	}
	
	func preferencesDidUpdate() {
		// check intervals and re-save them
		loadPreferences()
		savePreferences()
		
		showStatus()
	}
	
	override func awakeFromNib() {
		preferencesWindow = PreferencesWindow()
		preferencesWindow.delegate = self
		
		aboutWindow = AboutWindow()
		
		showSeconds = defaults.boolForKey("showSeconds")
		
		bt = Breaktimer(defaults.integerForKey("workInterval"), defaults.integerForKey("breakInterval"), defaults.integerForKey("maxIdleInterval"))
		
		bt.cyclesCount = defaults.integerForKey("cyclesCount")
		bt.cyclesResetIdleInterval = defaults.integerForKey("cyclesResetIdleInterval")
		
		if let lastCheckTime = defaults.objectForKey("lastCheckTime") {
			bt.checkCyclesCounter(Int(-lastCheckTime.timeIntervalSinceNow))
		}
		
		showStatus()
		statusItem.menu = statusMenu
		
		savePreferences()
		
		NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(showStatus), userInfo: nil, repeats: true)
	}
	
	
}
