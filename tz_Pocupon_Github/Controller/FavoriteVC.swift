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
    
    @IBOutlet weak var collectionView: UICollectionView!
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
        collectionView.reloadData()
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchResultController.fetchedObjects else { return 0 }
        if (UIDevice.current.orientation.isLandscape) {
            return (sections.count / 2 + sections.count % 2)
        }
        return (sections.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchResultController.fetchedObjects else { return 0 }
        if (UIDevice.current.orientation.isLandscape) {
            if (section == (sections.count / 2 + sections.count % 2 - 1) && (sections.count % 2) != 0) {
                return 1
            }
            return 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showViewCell", for: indexPath) as? ShowCollectionViewCell {
            let n = UIDevice.current.orientation.isLandscape ? 2 : 1
            let curentIndexPath = IndexPath(item: indexPath.row + n * indexPath.section, section: 0)
            let repo = self.fetchResultController.object(at: curentIndexPath) as! Repo
            configureCell(cell, repo)
            cell.addFavoriteButton.tag = indexPath.row + n * indexPath.section
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FavoriteVC.tapGestureAction))
            cell.addFavoriteButton.addGestureRecognizer(tapRecognizer)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let n = UIDevice.current.orientation.isLandscape ? 2 : 1
        let curentIndexPath = IndexPath(item: indexPath.row + n * indexPath.section, section: 0)
        performSegue(withIdentifier: "segueFromFavoriteToRepository", sender: self.fetchResultController.object(at: curentIndexPath) as! Repo)
    }
    
    // Configure Cell
    
    func configureCell(_ cell: ShowCollectionViewCell, _ repo: Repo) {
        cell.nameRepoLabel.text = repo.name
        cell.nameUserLabel.text = repo.owner_name
        cell.starsLabel.text = String(repo.stargazers_count)
        let language = repo.languege
        cell.languageLabel.text = language == nil ? "Unknown language" : language
        
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
            self.collectionView.reloadData()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FavoriteVC: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    }
}

// MARK: - Tratsition

extension FavoriteVC {
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }

}





