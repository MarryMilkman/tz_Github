//
//  RepositoryViewController.swift
//  tz_Pocupon_Github
//
//  Created by Ivan SELETSKYI on 10/30/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import UIKit
import CoreData

class RepositoryViewController: UIViewController {

    var customRepo: CustomDataRepo!
    var favoriteContext: NSManagedObjectContext?
    

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var owner_nameLabel: UILabel!
    @IBOutlet weak var owner_urlLabel: UILabel!
    @IBOutlet weak var create_atLAbel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var url_repoLabel: UILabel!
    @IBOutlet weak var url_gitLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var titleRepo: UINavigationItem!
    
    @IBOutlet weak var imageUser: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleRepo.title = customRepo.name
        owner_nameLabel.text = customRepo.owner_name
        owner_urlLabel.text = customRepo.owner_url
        starsLabel.text = String(describing: (customRepo.stargazers_count))
        languageLabel.text = customRepo.languege
        create_atLAbel.text = customRepo.create_at
        url_gitLabel.text = customRepo.git_url
        url_repoLabel.text = customRepo.clone_url
        
        let color = customRepo.isFavoryte ? UIColor.yellow : UIColor.gray
        favoriteButton.setTitleColor(color, for: favoriteButton.state)
        
        let urlStr = customRepo.owner_avatar
        get_image(urlStr, imageUser)
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        let button = sender
        
        if (favoriteContext == nil) {
            let context = PersistentService.backgroundContext
            let newRepo: Repo = Repo(context: context, represent: self.customRepo)
            
            context.perform {
                if (Repo.checkAndDel_ifStory_mainContext(newRepo, flagDel: true) == false)
                {
                    PersistentService.save(context: context)
                    DispatchQueue.main.async { button.setTitleColor(UIColor.yellow, for: button.state) }
                } else {
                    DispatchQueue.main.async { button.setTitleColor(UIColor.gray, for: button.state) }
                }
            }
        }
        else {
            let testContext = PersistentService.backgroundContext
            let testRepo = Repo(context: testContext, represent: self.customRepo)
            
            if (Repo.checkAndDel_ifStory(testRepo, flagDel: true, context: self.favoriteContext!) == false) {
                let _ = Repo(context: self.favoriteContext!, represent: self.customRepo)
                DispatchQueue.main.async { button.setTitleColor(UIColor.yellow, for: button.state) }
                PersistentService.save(context: self.favoriteContext!)
            }
            else {
                DispatchQueue.main.async { button.setTitleColor(UIColor.gray, for: button.state) }
            }
        }
    }

    
    func get_image(_ url_str: String, _ imageView: UIImageView){
        print("::", url_str)
        guard let url: URL = URL(string: url_str) else {
            print("Something wrong whith url")
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            DispatchQueue.main.async(execute: {
                if (data != nil){
                    let image = UIImage(data: data!)
                    if (image != nil){
                        imageView.image = image
                    }
                }
            })
        })
        task.resume()
    }

}






