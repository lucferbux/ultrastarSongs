//
//  SongTableViewController.swift
//  ultrastar
//
//  Created by lucas fernández on 03/01/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import UIKit
import Firebase

class SongTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    var ref: DatabaseReference!
    var items: [String:[Song]] = [:]
    var itemsFiltered: [String:[Song]] = [:]
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    var inSearchMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadTable()
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getKeys(songs: [String:[Song]]) -> [String] {
        let songKeys = [String](songs.keys)
        return songKeys.sorted(by: { $0 < $1 })
    }
    
    func getValues(songs: [String:[Song]]) -> [Song] {
        var values: [Song] = []
        for group in songs{
            values = values + group.value
        }
        return values
    }
    
    
    // MARK: fetch method
    
    func reloadTable() -> Void {
        self.showBlurredSpinner()
        ref = Database.database().reference(withPath: "songs")
        ref.queryOrdered(byChild: "Artist").observe(.value, with: { (snapshot) in
            var itemsAux: [String:[Song]] = [:]
            for item in snapshot.children {
                let newSong = Song(snapshot: item as! DataSnapshot)
                if var songSection = itemsAux[newSong.key]{
                    songSection.append(newSong)
                    itemsAux[newSong.key] = songSection
                } else {
                    itemsAux[newSong.key] = [newSong]
                }
            }
            self.items = itemsAux
            self.tableView.reloadData()
            self.hideSpinner()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let sections = inSearchMode ? itemsFiltered : items
        return sections.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let songs = inSearchMode ? itemsFiltered : items
        let songsKeys = getKeys(songs: songs)
        let songKey = songsKeys[section]
        if let songValues = songs[songKey] {
            return songValues.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        let songs = inSearchMode ? itemsFiltered : items
        let songKeys = getKeys(songs: songs)
        let songKey = songKeys[indexPath.section]
        
        if let songValues = songs[songKey]{
            let songItem = songValues[indexPath.row]
            cell.textLabel?.text = songItem.title
            cell.detailTextLabel?.text = songItem.artist
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let songs = inSearchMode ? itemsFiltered : items
        let songsKeys = getKeys(songs: songs)
        return songsKeys[section].uppercased()
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let songs = inSearchMode ? itemsFiltered : items
        let songsKeys = getKeys(songs: songs)
        return songsKeys.map( {$0.capitalized} )
    }
    

    //MARK: - Search data source
    
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            self.tableView.reloadData()
        } else {
            inSearchMode = true
            var itemsFilteredAux: [String:[Song]] = [:]
            let lower = searchBar.text!.lowercased()
            let itemValues = getValues(songs: items)
            let itemsFiltered = itemValues.filter({$0.artist.range(of: lower, options: .caseInsensitive) != nil || $0.title.range(of: lower, options: .caseInsensitive) != nil})
            
            for item in itemsFiltered {
                if var songSection = itemsFilteredAux[item.key]{
                    songSection.append(item)
                    itemsFilteredAux[item.key] = songSection
                } else {
                    itemsFilteredAux[item.key] = [item]
                }
            }
            self.itemsFiltered = itemsFilteredAux
            self.tableView.reloadData()
        }
    }
    
    func showBlurredSpinner() {
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        
        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = view.bounds
        
        // Label for vibrant indicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200)) //para el spinner
        activityIndicator.center = self.view.center //es para posicionar el lugar del spinner
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        
        
        // Add label to the vibrancy view
        vibrancyEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Add the vibrancy view to the blur view
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideSpinner() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        for subview in view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
    


}
