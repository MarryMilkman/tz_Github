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
            
            if let data = response.result.value as AnyObject? {
                self.repoArr = self.parsData(data)
                if (self.repoArr.count == 0) { self.doAlert("The user’s repository is empty or there is no such user.")}
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
    
    // Alert
    
    func doAlert(_ errorMessage: String) {
        let alert = UIAlertController(title: "Something wrong", message: errorMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alert, animated: true)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sectionInArr = repoArr.count
        if (UIDevice.current.orientation.isLandscape) {
            return (sectionInArr / 2 + sectionInArr % 2)
        }
        return (sectionInArr)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInArr = repoArr.count
        if (UIDevice.current.orientation.isLandscape) {
            if (section == (sectionInArr / 2 + sectionInArr % 2 - 1) && (sectionInArr % 2) != 0) {
                return 1
            }
            return 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showViewCell", for: indexPath) as? ShowCollectionViewCell {
            let n = UIDevice.current.orientation.isLandscape ? 2 : 1
            let index = indexPath.row + n * indexPath.section
            cell.nameRepoLabel.text = repoArr[index].name
            cell.nameUserLabel.text = repoArr[index].owner_name
            cell.starsLabel.text = String(repoArr[index].stargazers_count)
            let language = repoArr[index].languege
            cell.languageLabel.text = language == nil ? "Unknown language" : language
            
            let button = cell.addFavoriteButton!
            repoArr[index].isFavoryte ? button.setTitleColor(UIColor.yellow, for: button.state) : button.setTitleColor(UIColor.gray, for: button.state)
                                
            cell.addFavoriteButton.tag = index
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGestureAction))
            cell.addFavoriteButton.addGestureRecognizer(tapRecognizer)
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let n = UIDevice.current.orientation.isLandscape ? 2 : 1
        let index = indexPath.row + n * indexPath.section
        performSegue(withIdentifier: "segueFromVCToRepository", sender: repoArr[index])
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

// MARK: - Tratsition

extension ViewController {
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectView.reloadData()
    }
    
}
