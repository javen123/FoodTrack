//
//  ViewController.swift
//  FoodTracker
//
//  Created by user on 12/12/14.
//  Copyright (c) 2014 Neva. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var searchController:UISearchController!
    var suggestedSearchFoods: [String] = []
    var filteredSuggestedSearchFoods:[String] = []
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    var jsonResponse:NSDictionary!
    var apiSearchFoods:[(name:String, idValue:String)] = []
    var filteredFavoritedUSDAItems:[USDAItem] = []
    var datacontroller = DataController()
    var favoritedUSDAItems:[USDAItem] = []
    
    let kAppId = "825b61b4"
    let kAppKey = "9b6fa052b6ee832ebe2aa312e82afdcf"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        self.searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.suggestedSearchFoods = ["apples", "bagel", "beer", "banana", "bread", "carrots", "Cheddar Cheese", "Chicken Breast", "chili with beans", "chocolate chip cookies", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "rred wine", "rice", "shrimp", "spaghetti", "tuna", "white wine", "yellow cake"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: - UItableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        var foodName:String
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
            if selectedScopeButtonIndex == 0 {
                if self.searchController.active {
                    foodName = filteredSuggestedSearchFoods[indexPath.row]
                }
                else {
                    foodName = suggestedSearchFoods[indexPath.row]
                }
            }
            else if selectedScopeButtonIndex == 1 {
                foodName = apiSearchFoods[indexPath.row].name
            }
            else {
                foodName = self.favoritedUSDAItems[indexPath.row].name
            }
        
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {
                return self.filteredSuggestedSearchFoods.count
            }
            else {
                return self.suggestedSearchFoods.count
            }
        }
        else if selectedScopeButtonIndex == 1 {
            return self.apiSearchFoods.count
        }
        else {
            if self.searchController.active {
                return self.filteredFavoritedUSDAItems.count
            }
            
            return favoritedUSDAItems.count
        }
   }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedSopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedSopeButtonIndex == 0 {
            var searchFoodName:String
            if self.searchController.active {
                searchFoodName = filteredSuggestedSearchFoods[indexPath.row]
                
            }
            else {
                searchFoodName = suggestedSearchFoods[indexPath.row]
            }
            self.searchController.searchBar.selectedScopeButtonIndex = 1
            makeRequest(searchFoodName)
        }
        else if selectedSopeButtonIndex == 1 {
            let idValue = apiSearchFoods[indexPath.row].idValue
            self.datacontroller.saveUSDAItemForId(idValue, json: self.jsonResponse)
        }
        else {
            
        }
    }

    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        self.tableView.reloadData()
    }
    
    func filterContentForSearch (searchText:String, scope:Int) {
        if scope == 0 {
            self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food:String) -> Bool in
            var foodMatch = food.rangeOfString(searchText)
            return foodMatch != nil
            })
        }
        else if scope == 2 {
            self.filteredFavoritedUSDAItems = self.favoritedUSDAItems.filter({ (item: USDAItem) -> Bool in
                var stringMatch = item.name.rangeOfString(searchText)
                return stringMatch != nil
            })
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        makeRequest(searchBar.text)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if selectedScope == 2 {
            requestFavoritedUSDAItems()
        }
        self.tableView.reloadData()
    }
    
    func makeRequest (searchString: String) {
        
        var request = NSMutableURLRequest(URL: NSURL(string:"https://api.nutritionix.com/v1_1/search/")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        
        var params = [
            "appId":kAppId,
            "appKey": kAppKey,
            "fields":["item_name", "brand_name", "keywords",
            "usda_fields"],
            "limit":"50",
            "query": searchString,
            "filters":["exists": ["usda_fields": true]]]
        
        var error:NSError?
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
//            
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            print(stringData)
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &error) as? NSDictionary
            
            println(jsonDictionary)        
            if conversionError != nil {
                print(conversionError!.localizedDescription)
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in parsing \(errorString)")
            }
            else {
                if jsonDictionary != nil {
                    self.jsonResponse = jsonDictionary!
                    self.apiSearchFoods = DataController.jsonAsUSDAIdAndSearchResults(jsonDictionary!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                else {
                    let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON")
                }
            }
        })
        task.resume()
    }
    
    // MARK: Set up coreData
    
    func requestFavoritedUSDAItems () {
        let fetchRequest = NSFetchRequest(entityName: "USDAItem")
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        self.favoritedUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as [USDAItem]
        
    }
    
}

