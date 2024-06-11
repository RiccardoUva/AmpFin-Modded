//
//  AppDelegate.swift
//  Music
//
//  Created by Rasmus Krämer on 21.09.23.
//

import UIKit
import Intents

final class AppDelegate: NSObject, UIApplicationDelegate {
    private var backgroundCompletionHandler: (() -> Void)? = nil
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Task { @MainActor in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let backgroundCompletionHandler = appDelegate.backgroundCompletionHandler else {
                return
            }
            
            backgroundCompletionHandler()
        }
    }
    
    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
        switch intent {
            case is INPlayMediaIntent:
                return PlayMediaHandler()
            case is INAddMediaIntent:
                return AddMediaHandler()
            default:
                return nil
        }
    }
}
