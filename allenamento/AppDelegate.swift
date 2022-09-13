//
//  AppDelegate.swift
//  allenamento
//
//  Created by Enrico on 02/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Firebase
import GoogleSignIn
import GoogleMobileAds


let db = Firestore.firestore()
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

        
        //UINavigationBar.appearance().tintColor = UIColor.white
        
        //let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        //UINavigationBar.appearance().titleTextAttributes = textAttributes
        
        //CONTROLLI VARI
        //importante:
        ModelAddominali.shared.ControllaDatiTotali()
        print(CoreDataController.shared.caricaUserInfo().count)
        if CoreDataController.shared.caricaUserInfo().count != 1{
            DatabaseModel.shared.logOut()
        }
        //
        //var t = CoreDataController.shared.caricaStatAdd()[0]
        //print(t)
        
        /*
        for f in t.sessioni?.allObjects as! [SessioneAddominali]{
            print("add:\(f.giorno!) \(f.isInSessione) \(f.livelloSuperato) \(f.addFatti) \(f.tempo) \(f.livelloProvato)")
        }*/
        //------
        //var g = ModelFlessioni.shared.getInfoFlessioni()
        /*CoreDataController.shared.addSessioneInStatisticheFlessioni(giorno: Date(), isInSessione: false, livelloSuperato: false, flessFatte: 7, livelloProvato: 0, tempo: 12)
        g = ModelFlessioni.shared.getInfoFlessioni()*/
        
        //print(g)
        
        
        //------
        
        //firebase e google signin:
        //----
        /*
        for f in g.sessioni?.allObjects as! [SessioneFlessioni]{
            print("fless:\(f.giorno!) \(f.isInSessione) \(f.livelloSuperato) \(f.flessFatte) \(f.tempo) \(f.livelloProvato)")
            DatabaseModel.shared.addSessioneFlessioni(sessione: f)
            
        }
        for f in t.sessioni?.allObjects as! [SessioneAddominali]{
            print("add:\(f.giorno!) \(f.isInSessione) \(f.livelloSuperato) \(f.addFatti) \(f.tempo) \(f.livelloProvato)")
            DatabaseModel.shared.addSessioneAdd(sessione: f)
        }*/
        
        UNUserNotificationCenter.current().delegate = self
        //CoreDataController.shared.cancellaStatisticheAdd()
        return true//problemi: Record non va bene - Add fatti e tempo non corretti
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "allenamento")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

