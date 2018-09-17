//
//  LessonViewController.swift
//  Umbrella
//
//  Created by Lucas Correa on 05/07/2018.
//  Copyright © 2018 Security First. All rights reserved.
//

import UIKit

class LessonViewController: UIViewController {
    
    //
    // MARK: - Properties
    lazy var lessonViewModel: LessonViewModel = {
        let lessonViewModel = LessonViewModel()
        return lessonViewModel
    }()
    @IBOutlet weak var lessonTableView: UITableView!
    
    //
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LessonViewController.loadTent(notification:)), name: Notification.Name("UmbrellaTent"), object: nil)
        
        self.title = "Lessons".localized()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lessonTableView?.register(CategoryHeaderView.nib, forHeaderFooterViewReuseIdentifier: CategoryHeaderView.identifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //
    // MARK: - Functions
    
    /// Receive the tent by notification
    ///
    /// - Parameter notification: notification with umbrella
    @objc func loadTent(notification: Notification) {
        let umbrella = notification.object as? Umbrella
        
        self.lessonViewModel.umbrella = umbrella
        
        if let tableview = self.lessonTableView {
            tableview.reloadData()
        }
    }
    
    //
    // MARK: - UIStoryboardSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "difficultySegue" {
            let difficultyViewController = (segue.destination as? DifficultyViewController)!
            
            let category = (sender as? Category)!
            difficultyViewController.difficultyViewModel.categoryParent = category
            //Sort by Index
            category.categories.sort(by: { $0.index! < $1.index!})
            difficultyViewController.difficultyViewModel.difficulties = category.categories
        }
    }
}

// MARK: - UITableViewDataSource
extension LessonViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.lessonViewModel.categories(ofLanguage: Locale.current.languageCode!).count + 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // if section == 0 so it is Favourites header
        if section == 0 {
            return 0
        }
        
        let headerItem = self.lessonViewModel.categories(ofLanguage: Locale.current.languageCode!)[section - 1]
        
        // if section is in array as collapsed when it should return the count of items of category
        if self.lessonViewModel.isCollapsed(section: section) {
            return headerItem.categories.count
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CategoryCell = (tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell)!
        cell.configure(withViewModel: self.lessonViewModel, indexPath: indexPath)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LessonViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CategoryHeaderView.identifier) as? CategoryHeaderView {
            
            if section == 0 {
                headerView.nameLabel.text = "Favourites".localized()
                headerView.arrowImageView.isHidden = true
                headerView.iconImageView.image = #imageLiteral(resourceName: "iconFavourite")
            } else {
                let item = self.lessonViewModel.categories(ofLanguage: Locale.current.languageCode!)[section - 1]
                headerView.nameLabel.text = item.name
                headerView.arrowImageView.isHidden = item.categories.count == 0
                let file = "\(item.folderName ?? "")\(item.icon ?? "")"
                headerView.iconImageView.image = UIImage(contentsOfFile: file)
            }
            
            headerView.section = section
            headerView.delegate = self
            headerView.nameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            if headerView.iconImageView.image != nil {
                headerView.iconImageView.image = headerView.iconImageView.image!.withRenderingMode(.alwaysTemplate)
            }
            
            headerView.iconImageView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            // if section is in array as collapsed when it change color of the name and icon.
            if self.lessonViewModel.isCollapsed(section: section) {
                headerView.setCollapsed(collapsed: true)
                headerView.nameLabel.textColor = #colorLiteral(red: 0.7787129283, green: 0.3004907668, blue: 0.4151412845, alpha: 1)
                headerView.iconImageView.tintColor = #colorLiteral(red: 0.7787129283, green: 0.3004907668, blue: 0.4151412845, alpha: 1)
            }
            
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let headerItem = self.lessonViewModel.categories(ofLanguage: Locale.current.languageCode!)[indexPath.section - 1]
        let category = headerItem.categories[indexPath.row]
        
        self.performSegue(withIdentifier: "difficultySegue", sender: category)
    }
}

extension LessonViewController: CategoryHeaderViewDelegate {
    func toggleSection(header: CategoryHeaderView, section: Int) {
        
        var collapsed = false
        if self.lessonViewModel.isCollapsed(section: section) {
            if let index = self.lessonViewModel.sectionsCollapsed.index(of: section) {
                self.lessonViewModel.sectionsCollapsed.remove(at: index)
            }
            collapsed = false
        } else if section == 0 {
            print("Go the favourites")
        } else if self.lessonViewModel.categories(ofLanguage: Locale.current.languageCode!)[section - 1].categories.count == 0 {
            print("Go to segment")
        } else {
            collapsed = true
            self.lessonViewModel.sectionsCollapsed.append(section)
        }
        
        header.setCollapsed(collapsed: collapsed)
        self.lessonTableView.reloadSections([section], with: UITableViewRowAnimation.fade)
        
        // I needed to put this code because there is a bug when the tableview is in scroll then I do a collapse in some section.
        self.lessonTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension LessonViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}
