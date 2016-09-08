//
//  NotificationHelper.swift
//  Prioto
//
//  Created by Kha Nguyen on 8/1/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation

class NotificationHelper {
    
    static func userInfoForCategory(category: String) -> [NSObject: AnyObject] {
        
        if category == "WORKTIME_UP" {
            return ["aps": [
                "category": category,
                "alert": [
                    "body": "Work time is up!",
                    "title": "Prioto"
                ],
                "sound": "sound.wav"
                ]
            ]
        }
            
        else if category == "BREAKTIME_UP" {
            return ["aps": [
                "category": category,
                "alert": [
                    "body": "Break time is up",
                    "title": "Prioto"
                ],
                "sound": "sound.wav"
                ]
            ]
            
        }
            
        else if category == "START_TIMER" {
            return ["aps": [
                "category": category,
                "alert": [
                    "body": "Timer unpaused",
                    "title": "Prioto"
                ],
                "sound": "sound.wav"
                ]
            ]
            
        }
            
        else {
            return ["aps": [
                "category": category,
                "alert": [
                    "body": category,
                    "title": "Task Reminder"
                ],
                "sound": "sound.wav"
                ]
            ]
        }
    }
}