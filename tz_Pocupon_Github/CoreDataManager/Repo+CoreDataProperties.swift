//
//  Repo+CoreDataProperties.swift
//  tz_Pocupon_Github
//
//  Created by Ivan SELETSKYI on 10/30/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//
//

import Foundation
import CoreData


extension Repo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Repo> {
        return NSFetchRequest<Repo>(entityName: "Repo")
    }

    @NSManaged public var name: String?
    @NSManaged public var full_name: String?
    @NSManaged public var html_url: String?
    @NSManaged public var create_at: String?
    @NSManaged public var git_url: String?
    @NSManaged public var clone_url: String?
    @NSManaged public var stargazers_count: Int32
    @NSManaged public var languege: String?
    @NSManaged public var owner_name: String?
    @NSManaged public var owner_avatar: String?
    @NSManaged public var owner_url: String?

}
