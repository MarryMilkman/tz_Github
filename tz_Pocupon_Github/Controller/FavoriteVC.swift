//
//  FavoriteVC.swift
//  tz_Pocupon_Github
//
//  Created by Ivan SELETSKYI on 10/31/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import UIKit
import CoreData

class FavoriteVC: UIViewController {
    
    @IBOutlet weak var celectionView: UICollectionView!
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
    let globalContext: NSManagedObjectContext = PersistentService.context
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let objectType: NSManagedObject.Type = Repo.self
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = []
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: globalContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
        } catch {
            print(error)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        celectionView.reloadData()
    }
    
    // Segue prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueFromFavoriteToRepository") {
            let vc = segue.destination as? RepositoryViewController
            vc?.customRepo = CustomDataRepo(repo: (sender as! Repo))
            vc?.favoriteContext = globalContext
        }
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension FavoriteVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchResultController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showViewCell", for: indexPath) as? ShowCollectionViewCell {
            let repo = self.fetchResultController.object(at: indexPath) as! Repo
            configureCell(cell, repo)
            cell.addFavoriteButton.tag = indexPath.row
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FavoriteVC.tapGestureAction))
            cell.addFavoriteButton.addGestureRecognizer(tapRecognizer)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueFromFavoriteToRepository", sender: self.fetchResultController.object(at: indexPath) as! Repo)
    }
    
    // Configure Cell
    
    func configureCell(_ cell: ShowCollectionViewCell, _ repo: Repo) {
        cell.nameRepoLabel.text = repo.name
        cell.nameUserLabel.text = repo.owner_name
        cell.dateCreateLabel.text = repo.create_at
        cell.starsLabel.text = String(repo.stargazers_count)
        cell.languageLabel.text = repo.languege
        
        let button = cell.addFavoriteButton!
        button.setTitleColor(UIColor.yellow, for: button.state)
    }
}

// MARK: - Recognizer

extension FavoriteVC {
    @objc func tapGestureAction(sender: UITapGestureRecognizer) {
        guard let button = sender.view as? UIButton else { return }
        let index = button.tag
        
        let repoArr = self.fetchResultController.sections![0].objects as! [Repo]
        let repo = repoArr[index]
        if (Repo.checkAndDel_ifStory(repo, flagDel: true, context: globalContext)) {
            self.celectionView.reloadData()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FavoriteVC: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("ZALUPA!!!!!!!!!!!!!")
    }

}





