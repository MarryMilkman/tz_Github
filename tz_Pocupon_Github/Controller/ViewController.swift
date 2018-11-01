//
//  ViewController.swift
//  tz_Pocupon_Github
//
//  Created by Ivan SELETSKYI on 10/30/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var collectView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    var repoArr: [CustomDataRepo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        if (repoArr.count > 0) {
            self.checkFavoriteItData()
            collectView.reloadData()
        }
    }
    
    @IBAction func favoriteAction(_ sender: Any) {
        performSegue(withIdentifier: "segueFromVCToFavorite", sender: nil)
    }

    
    // Get Requst
    
    func getRequst(_ name: String) {
        if (name == "") {return}
        
        guard let url = URL(string: "https://api.github.com/users/\(name)/repos") else {return}
        Alamofire.request(url).responseJSON { (response) in
            if let error = response.error {
                print(error)
                return
            }
            print(response.response ?? "error")
            
            if let data = response.result.value as AnyObject? {
                self.repoArr = self.parsData(data)
                self.checkFavoriteItData()
            }
            self.collectView.reloadData()
        }
    }
    
    // Pars
    
    func parsData(_ data: AnyObject) -> [CustomDataRepo] {
        var rbox = [CustomDataRepo]()
        guard let data = data as? [[String: Any]] else {return [CustomDataRepo]()}
        var i: Int = 0
        
        while (i < data.count) {
            var elem = CustomDataRepo()
            elem.clone_url = data[i]["clone_url"] as! String
            elem.create_at = data[i]["created_at"] as! String
            elem.full_name = data[i]["full_name"] as! String
            elem.git_url = data[i]["git_url"] as! String
            elem.html_url = data[i]["html_url"] as! String
            elem.languege = data[i]["language"] as? String
            elem.name = data[i]["name"]! as! String
            elem.stargazers_count = Int32(data[i]["stargazers_count"] as! Int)
            
            let dataUserProp = data[i]["owner"]! as! [String: Any]
            elem.owner_avatar = dataUserProp["avatar_url"]! as! String
            elem.owner_name = dataUserProp["login"]! as! String
            elem.owner_url = dataUserProp["url"]! as! String
            rbox.append(elem)
            i += 1
        }
        return rbox
    }
    
    // Check Favorite in Data
    
    func checkFavoriteItData () {
        let context = PersistentService.backgroundContext
        
        let fetchArr = PersistentService.fetch(context: context, Repo.self) as! [Repo]
        var count = 0
        
        for elem in self.repoArr {
            self.repoArr[count].isFavoryte = false
            for repoElem in fetchArr {
                if (repoElem.full_name == elem.full_name){
                    self.repoArr[count].isFavoryte = true
                    break
                }
            }
            count += 1
        }
    }
    
    // Segue prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueFromVCToRepository") {
            let vc = segue.destination as? RepositoryViewController
            vc?.customRepo = sender as! CustomDataRepo
        }
    }
}

//  MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return repoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showViewCell", for: indexPath) as? ShowCollectionViewCell {
            cell.nameRepoLabel.text = repoArr[indexPath.row].name
            cell.nameUserLabel.text = repoArr[indexPath.row].owner_name
            cell.dateCreateLabel.text = repoArr[indexPath.row].create_at
            cell.starsLabel.text = String(repoArr[indexPath.row].stargazers_count)
            cell.languageLabel.text = repoArr[indexPath.row].languege
            
            let button = cell.addFavoriteButton!
            repoArr[indexPath.row].isFavoryte ? button.setTitleColor(UIColor.yellow, for: button.state) : button.setTitleColor(UIColor.gray, for: button.state)
                                
            cell.addFavoriteButton.tag = indexPath.row
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGestureAction))
            cell.addFavoriteButton.addGestureRecognizer(tapRecognizer)
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueFromVCToRepository", sender: repoArr[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        DispatchQueue.main.async {
            self.getRequst(searchBar.text!)
        }
        
    }
}

// Gestures

extension ViewController {
    
    @objc func tapGestureAction(sender: UITapGestureRecognizer) {
        guard let button = sender.view as? UIButton else { return }
        let index = button.tag
        let context = PersistentService.backgroundContext
        
        context.perform {
            let repo = Repo(context: context, represent: self.repoArr[index])
            if (Repo.checkAndDel_ifStory_mainContext(repo, flagDel: true) == false) {
                PersistentService.save(context: context)
                DispatchQueue.main.async {
                    self.repoArr[index].isFavoryte = true
                    button.setTitleColor(UIColor.yellow, for: button.state)
                }
            } else {
                DispatchQueue.main.async {
                    self.repoArr[index].isFavoryte = false
                    button.setTitleColor(UIColor.gray, for: button.state)
                }
            }
        }
    }
}

