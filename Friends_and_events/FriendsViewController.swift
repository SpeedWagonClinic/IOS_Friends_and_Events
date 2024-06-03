import UIKit
import CoreData

// ViewController to handle displaying and managing friends
class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    // Outlets for the UI elements
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchModeSegmentedControl: UISegmentedControl!

    // Arrays to store all friends and filtered friends for the search functionality
    var friends: [Friend] = []
    var filteredFriends: [Friend] = []
    // Core Data context for fetching and saving data
    var context: NSManagedObjectContext!
    // Array to store selected index paths for editing or deleting friends
    var selectedIndexPaths: [IndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the table view data source and delegate
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.allowsMultipleSelection = true
        
        // Setting up the search bar delegate and segmented control action
        searchBar.delegate = self
        searchModeSegmentedControl.addTarget(self, action: #selector(searchModeChanged(_:)), for: .valueChanged)
        
        // Register to receive notifications when a new friend is added
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name("FriendAdded"), object: nil)
        
        // Load the initial data and update button states
        loadData()
        updateEditButtonState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("FriendAdded"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        updateEditButtonState()
    }
    
    // Action for the delete button to delete the selected friends
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard !selectedIndexPaths.isEmpty else {
            print("No friends selected to delete.")
            return
        }
        deleteFriends(at: selectedIndexPaths)
    }
    
    // Action for the edit button to edit the selected friend
    @IBAction func editButtonTapped(_ sender: UIButton) {
        guard selectedIndexPaths.first != nil else {
            print("No friend selected to edit.")
            return
        }
        performSegue(withIdentifier: "EditFriendSegue", sender: self)
    }
    
    // Prepare for segue to EditFriendViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditFriendSegue",
           let destinationVC = segue.destination as? EditFriendViewController,
           let indexPath = selectedIndexPaths.first {
            destinationVC.friend = friends[indexPath.row]
        }
    }
    
    // Method to load friends from Core Data
    @objc func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        do {
            friends = try context.fetch(request)
            print("Fetched \(friends.count) friends.")
            filteredFriends = friends
            friendsTableView.reloadData()
        } catch {
            print("Failed to fetch friends: \(error)")
        }
    }
    
    // UITableViewDataSource method to return the number of rows in the section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count
    }
    
    // UITableViewDataSource method to configure the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        
        let friend = filteredFriends[indexPath.row]
        let fullname = friend.fullname ?? ""
        let gender = friend.gender ?? ""
        let phoneNum = friend.phoneNum ?? ""
        
        cell.textLabel?.text = "\(fullname), \(gender), \(phoneNum)"
        
        // Set avatar image or default icon
        if let avatarData = friend.avatar {
            cell.imageView?.image = UIImage(data: avatarData)
        } else {
            cell.imageView?.image = UIImage(systemName: "person.circle")
        }
        
        return cell
    }
    
    // UITableViewDelegate method to handle selection of a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPaths.append(indexPath)
        updateEditButtonState()
    }
    
    // UITableViewDelegate method to handle deselection of a row
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedIndexPaths.firstIndex(of: indexPath) {
            selectedIndexPaths.remove(at: index)
        }
        updateEditButtonState()
    }
    
    // Method to delete selected friends from Core Data
    func deleteFriends(at indexPaths: [IndexPath]) {
        let friendsToDelete = indexPaths.map { filteredFriends[$0.row] }
        
        for friend in friendsToDelete {
            context.delete(friend)
        }
        
        do {
            try context.save()
            
            for indexPath in indexPaths.sorted(by: { $0.row > $1.row }) {
                friends.remove(at: indexPath.row)
                filteredFriends = friends
                friendsTableView.deleteRows(at: [indexPath], with: .fade)
            }
            selectedIndexPaths.removeAll()
        } catch {
            print("Failed to delete friends: \(error)")
        }
        updateEditButtonState()
    }

    // UISearchBarDelegate method to filter friends based on search text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFriends(for: searchText)
    }
    
    // UISearchBarDelegate method to dismiss the keyboard when search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // Method to handle changes in the search mode segmented control
    @objc func searchModeChanged(_ sender: UISegmentedControl) {
        filterFriends(for: searchBar.text ?? "")
    }
    
    // Method to filter friends based on the search text and selected search mode
    func filterFriends(for searchText: String) {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
            switch searchModeSegmentedControl.selectedSegmentIndex {
            case 0: // Search by name
                filteredFriends = friends.filter { friend in
                    return friend.fullname?.lowercased().contains(searchText.lowercased()) ?? false
                }
            case 1: // Search by phone number
                filteredFriends = friends.filter { friend in
                    return friend.phoneNum?.lowercased().contains(searchText.lowercased()) ?? false
                }
            case 2: // Search by hobbies
                filteredFriends = friends.filter { friend in
                    return friend.hobbies?.lowercased().contains(searchText.lowercased()) ?? false
                }
            default:
                filteredFriends = friends
            }
        }
        friendsTableView.reloadData()
    }
    
    // Method to update the state of the edit and delete buttons
    func updateEditButtonState() {
        editButton.isEnabled = !selectedIndexPaths.isEmpty
        deleteButton.isEnabled = !selectedIndexPaths.isEmpty
    }
}
