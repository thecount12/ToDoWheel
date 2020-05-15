//
//  CategoryViewController.swift
//  ToDoWheel
//
//  Created by William Gunnells on 4/28/20.
//  Copyright © 2020 William Gunnells. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: UITableViewController {

    var categories = [`Category`]()
    
    var selectedSpoke : Spoke? {
        didSet {
            loadCategory()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
        tableView.rowHeight = 80.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedSpoke!.spoke_name
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        navBar.barTintColor = UIColor(hexString: "707070")
    }

    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categories[indexPath.row].name
        cell.backgroundColor = UIColor(hexString: categories[indexPath.row].cat_color ?? "1D9Bf6")
        cell.delegate = self
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
//        tableView.reloadData()
    }
    
    func loadCategory(with request: NSFetchRequest<Category> = Category.fetchRequest(), predicate: NSPredicate? = nil) {
           let spokesPredicate = NSPredicate(format: "parentSpoke.spoke_name MATCHES %@", selectedSpoke!.spoke_name!)
           if let additionalPredicate = predicate {
               request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [spokesPredicate, additionalPredicate])
           } else {
               request.predicate = spokesPredicate
           }

           do {
               categories = try context.fetch(request)
           } catch {
               print("Error fetching data from context \(error)")
           }
           tableView.reloadData()
       }
    
//    func loadCategories () {
//
//        let request : NSFetchRequest<Category> = Category.fetchRequest()
//        do {
//        categories = try context.fetch(request)
//        } catch {
//            print("Error loading categories \(error)")
//        }
//        tableView.reloadData()
//    }
//
    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add detail Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem = Category(context: self.context)
            print("Success!")
            print(textField.text!)

            newItem.name = textField.text!
            newItem.cat_color = UIColor.randomFlat().hexValue()
            newItem.parentSpoke = self.selectedSpoke
            self.categories.append(newItem)
            self.saveCategories()
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
        alertTextField.placeholder = "Create new item"
        textField = alertTextField
        print(alertTextField.text!)
         }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
}

//MARK: - Swipe Cell Delegate Methods

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Item deleted")
            self.context.delete(self.categories[indexPath.row])
            self.categories.remove(at: indexPath.row)
            self.saveCategories()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon.png")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        // options.transitionStyle = .border
        return options
    }
}

