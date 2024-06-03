import UIKit
import CoreData

// ViewController to handle adding a new event
class AddEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Outlets for the UI elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var friendsTableView: UITableView!
    
    // Array to store friends fetched from Core Data
    var friends: [NSManagedObject] = []
    // Set to store selected friends for the event
    var selectedFriends: Set<NSManagedObject> = []
    // Core Data context for fetching and saving data
    var context: NSManagedObjectContext!
    
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
        
        // Load friends from Core Data
        loadFriends()
    }
    
    // Method to fetch friends from Core Data
    func loadFriends() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Friend")
        do {
            friends = try context.fetch(request)
            friendsTableView.reloadData()
        } catch {
            print("Failed to fetch friends: \(error)")
        }
    }
    
    // Action for the add event button
    @IBAction func addEvent(_ sender: UIButton) {
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: context)!
        let newEvent = NSManagedObject(entity: entity, insertInto: context)
        
        // Set the attributes for the new event
        newEvent.setValue(nameTextField.text, forKey: "name")
        newEvent.setValue(locationTextField.text, forKey: "location")
        newEvent.setValue(datePicker.date, forKey: "date")
        newEvent.setValue(NSSet(set: selectedFriends), forKey: "friends")
        
        // Save the new event to Core Data
        do {
            try context.save()
            print("Event saved: \(newEvent.value(forKey: "name") as? String ?? "No name")")
        } catch {
            print("Failed to save event: \(error)")
        }
    }
    
    // Action for the cancel button
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // UITableViewDataSource method to return the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    // UITableViewDataSource method to configure the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        let friend = friends[indexPath.row]
        
        // Set cell text with friend's details
        let fullname = friend.value(forKey: "fullname") as? String ?? ""
        let gender = friend.value(forKey: "gender") as? String ?? ""
        let phoneNum = friend.value(forKey: "phoneNum") as? String ?? ""
        cell.textLabel?.text = "\(fullname), \(gender), \(phoneNum)"
        
        return cell
    }
    
    // UITableViewDelegate method to handle selection of a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        selectedFriends.insert(friend)
    }
    
    // UITableViewDelegate method to handle deselection of a row
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        selectedFriends.remove(friend)
    }
}
