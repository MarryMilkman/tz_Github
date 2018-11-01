//
//  parsData.swift
//  tz_Pocupon_Github
//
//  Created by Ivan SELETSKYI on 10/30/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import Foundation

struct CustomDataRepo: Decodable {
    var name: String
    var full_name: String
    var html_url: String
    var create_at: String
    var git_url: String
    var clone_url: String
    var stargazers_count: Int32
    var languege: String?
    var owner_name: String
    var owner_avatar: String
    var owner_url: String
    var isFavoryte: Bool
    
    init() {
        name = ""
        full_name = ""
        html_url = ""
        create_at = ""
        git_url = ""
        clone_url = ""
        stargazers_count = 0
        languege = ""
        owner_name = ""
        owner_avatar = ""
        owner_url = ""
        isFavoryte = false
    }
    
    init(repo: Repo) {
        name = repo.name!
        full_name = repo.full_name!
        html_url = repo.html_url!
        create_at = repo.create_at!
        git_url = repo.git_url!
        clone_url = repo.clone_url!
        stargazers_count = repo.stargazers_count
        languege = repo.languege
        owner_name = repo.owner_name!
        owner_avatar = repo.owner_avatar!
        owner_url = repo.owner_url!
        isFavoryte = true
    }
}
