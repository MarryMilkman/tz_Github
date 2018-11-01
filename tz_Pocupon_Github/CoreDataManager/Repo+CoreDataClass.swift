//
//  Repo+CoreDataClass.swift
//  tz_Pocupon_Github
//
//  Created by Ivan SELETSKYI on 10/30/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Repo)
public class Repo: NSManagedObject {
    convenience init (context: NSManagedObjectContext) {

        let objectType: NSManagedObject.Type = Repo.self
        let entityName = String(describing: objectType)
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)

        self.init(entity: entity!, insertInto: context)
    }

    convenience init (context: NSManagedObjectContext, represent: Repo) {

        let objectType: NSManagedObject.Type = Repo.self
        let entityName = String(describing: objectType)
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        
        self.init(entity: entity!, insertInto: context)
        self.clone_url = represent.clone_url
        self.create_at = represent.create_at
        self.full_name = represent.full_name
        self.git_url = represent.git_url
        self.html_url = represent.html_url
        self.languege = represent.languege
        self.name = represent.name
        self.owner_avatar = represent.owner_avatar
        self.owner_url = represent.owner_url
        self.owner_name = represent.owner_name
        self.stargazers_count = represent.stargazers_count
    }
    
    convenience init (context: NSManagedObjectContext, represent: CustomDataRepo) {
        
        let objectType: NSManagedObject.Type = Repo.self
        let entityName = String(describing: objectType)
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        
        self.init(entity: entity!, insertInto: context)
        self.clone_url = represent.clone_url
        self.create_at = represent.create_at
        self.full_name = represent.full_name
        self.git_url = represent.git_url
        self.html_url = represent.html_url
        self.languege = represent.languege
        self.name = represent.name
        self.owner_avatar = represent.owner_avatar
        self.owner_url = represent.owner_url
        self.owner_name = represent.owner_name
        self.stargazers_count = represent.stargazers_count
    }
    
    static func checkAndDel_ifStory_mainContext(_ repo: Repo, flagDel: Bool) -> Bool {
        let context = PersistentService.context
        
        let fetchRepo = PersistentService.fetch(context: context, Repo.self) as! [Repo]
        var i = 0
        
        while (i < fetchRepo.count) {
            if (repo.full_name == fetchRepo[i].full_name) {
                if (flagDel) {
                    context.delete(fetchRepo[i])
                    PersistentService.save(context: context)
                }
                return true
            }
            i += 1
        }
        return false
    }
    
    static func checkAndDel_ifStory(_ repo: Repo, flagDel: Bool, context: NSManagedObjectContext) -> Bool {
        
        let fetchRepo = PersistentService.fetch(context: context, Repo.self) as! [Repo]
        var i = 0
        
        while (i < fetchRepo.count) {
            if (repo.full_name == fetchRepo[i].full_name) {
                if (flagDel) {
                    context.delete(fetchRepo[i])
                    PersistentService.save(context: context)
                }
                return true
            }
            i += 1
        }
        return false
    }
}
