
import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var restaurants:[CKRecord] = []
    var imageCache = NSCache<CKRecordID, NSURL>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch restaurant records from iCloud
        fetchRecordsFromCloud()
        
        // Enable the spinner
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.startAnimating()
        
        // Pull To Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControlEvents.valueChanged)
        
        // Enable Self Sizing Cells
        tableView.estimatedRowHeight = 249.0
        tableView.rowHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper Methods
    
/*    func fetchRecordsFromCloud() {
        
        // Fetch data using Convenience API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            
            if let results = results {
                print("Completed the download of Restaurant data")
                self.restaurants = results
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
                
            }
        })
    }*/

    func fetchRecordsFromCloud() {
        
        // Remove existing records before refreshing
        restaurants.removeAll()
        tableView.reloadData()
        
        // Fetch data using Convenience API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the query operation with the query
        let queryOperation = CKQueryOperation(query: query)
        
        // Solution to Exercise
        queryOperation.desiredKeys = ["name", "type", "location"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.restaurants.append(record)
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if let error = error {
                print("Failed to get data from iCloud - \(error.localizedDescription)")
                return
            }
            
            print("Successfully retrieve the data from iCloud")
            OperationQueue.main.addOperation {
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
        
        // Execute the query
        publicDatabase.add(queryOperation)
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantTableViewCell

        // Configure the cell...
        let restaurant = restaurants[indexPath.row]
        cell.nameLabel.text = restaurant.object(forKey: "name") as? String
        cell.typeLabel.text = restaurant.object(forKey: "type") as? String
        cell.locationLabel.text = restaurant.object(forKey: "location") as? String
//        cell.textLabel?.text = restaurant.object(forKey: "name") as? String
        
        // Set the default image
        cell.thumbnailImageView.image = UIImage(named: "photoalbum")
        
        // Check if the image is stored in cache
        if let imageFileURL = imageCache.object(forKey: restaurant.recordID) {
            // Fetch image from cache
            print("Get image from cache")
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                cell.thumbnailImageView.image = UIImage(data: imageData)
            }
            
        } else {
            // Fetch Image from Cloud in background
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            
            fetchRecordsImageOperation.perRecordCompletionBlock = { (record, recordID, error) -> Void in
                if let error = error {
                    print("Failed to get restaurant image: \(error.localizedDescription)")
                    return
                }
                
                if let restaurantRecord = record {
                    OperationQueue.main.addOperation() {
                        if let image = restaurantRecord.object(forKey: "image") {
                            let imageAsset = image as! CKAsset
                            
                            if let imageData = try? Data.init(contentsOf: imageAsset.fileURL) {
                                cell.thumbnailImageView.image = UIImage(data: imageData)
                            }
                            
                            // Add the image URL to cache
                            self.imageCache.setObject(imageAsset.fileURL as NSURL, forKey: restaurant.recordID)
                        }
                    }
                }
            }
            
            publicDatabase.add(fetchRecordsImageOperation)
        }
        
        return cell
    }
    
}
