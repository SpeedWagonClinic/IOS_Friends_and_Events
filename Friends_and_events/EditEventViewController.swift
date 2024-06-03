import UIKit
import CoreData

// ViewController to handle editing an existing event
class EditEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Outlets for the UI elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var friendsTableView: UITableView!
    
    // The event to be edited
    var event: NSManagedObject!
    // Array to store all friends fetched from Core Data
    var allFriends: [NSManagedObject] = []
    // Set to store friends assigned to the event
    var assignedFriends: Set<NSManagedObject> = []
    // Core Data context for fetching and saving data
    var context: NSManagedObjectContext!
    // Delegate to notify of event updates
    weak var delegate: EditEventDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the table view data source and delegate
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.allowsMultipleSelection = true
        
        // Obtain the Core Data context from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        context = appDelegate.persistentContainer.viewContext
        
        // Load event details and friends from Core Data
        loadEventDetails()
        loadFriends()
    }
    
    // Method to load the details of the event to be edited
    func loadEventDetails() {
        guard let event = event else { return }
        nameTextField.text = event.value(forKey: "name") as? String
        locationTextField.text = event.value(forKey: "location") as? String
        if let eventDate = event.value(forKey: "date") as? Date {
            datePicker.date = eventDate
        }
        if let friends = event.value(forKey: "friends") as? Set<NSManagedObject> {
            assignedFriends = friends
        }
    }
    
    // Method to fetch all friends from Core Data
    func loadFriends() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Friend")
        do {
            allFriends = try context.fetch(request)
            friendsTableView.reloadData()
        } catch {
            print("Failed to fetch friends: \(error)")
        }
    }
    
    // Action for the save button to update the event
    @IBAction func saveEvent(_ sender: UIButton) {
        guard let event = event else { return }
        event.setValue(nameTextField.text, forKey: "name")
        event.setValue(locationTextField.text, forKey: "location")
        event.setValue(datePicker.date, forKey: "date")
        event.setValue(assignedFriends as NSSet, forKey: "friends")
        
        // Save the updated event to Core Data
        do {
            try context.save()
            print("Event updated: \(event.value(forKey: "name") as? String ?? "No name")")
            delegate?.eventDidUpdate(event) // Notify the delegate
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to save event: \(error)")
        }
    }
    
    // Action for the cancel button to dismiss the view controller
    @IBAction func cancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true) 
    }
    
    // UITableViewDataSource method to return the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFriends.count
    }

    // UITableViewDataSource method to configure the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        
        let friend = allFriends[indexPath.row]
        let fullname = friend.value(forKey: "fullname") as? String ?? ""
        let gender = friend.value(forKey: "gender") as? String ?? ""
        let phoneNum = friend.value(forKey: "phoneNum") as? String ?? ""

        // Set cell text with friend's details
        cell.textLabel?.text = "\(fullname), \(gender), \(phoneNum)"
        // Highlight the cell if the friend is assigned to the event
        cell.backgroundColor = assignedFriends.contains(friend) ? UIColor.lightGray : UIColor.white
        
        return cell
    }
    
    // UITableViewDelegate method to handle selection of a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = allFriends[indexPath.row]
        if assignedFriends.contains(friend) {
            assignedFriends.remove(friend)
        } else {
            assignedFriends.insert(friend)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // UITableViewDelegate method to handle deselection of a row
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let friend = allFriends[indexPath.row]
        if assignedFriends.contains(friend) {
            assignedFriends.remove(friend)
        } else {
            assignedFriends.insert(friend)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
