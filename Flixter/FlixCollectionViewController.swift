//
//  FlixCollectionViewController.swift
//  Flixter
//
//  Created by Che Chao Hsu on 1/24/16.
//  Copyright © 2016 Che Chao Hsu. All rights reserved.
//


import UIKit
import AFNetworking
import MBProgressHUD

class FlixCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movies: [NSDictionary]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.barTintColor = UIColor.darkGrayColor()
        
        // Init cells as FlixCollectionViewController to be DataSource and Delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Initialize a UIView for Network Error   ableView.insertSubview(netErrControl, atIndex: 0)
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                        NSLog("response: \(responseDictionary)")
                        
                        // Display HUD right before next request is made
                        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        progressHUD.labelText = "Loading..."
                        self.movies = responseDictionary["results"] as! [NSDictionary]
                        self.collectionView.reloadData()
                        progressHUD.hide(true, afterDelay: 0.5)
                        self.networkErrorView.hidden = true
                    }
                }
        });
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If movies is not nil, assign to const movies
        if let movies = movies {
            print ("Network Connected...")
            return movies.count
        }
        else {
            print ("Network Disconnected...")
            self.networkErrorView.hidden = false
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlixCollectionCell", forIndexPath: indexPath) as! FlixCollectionCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        
        return cell
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // Make network request to fetch latest data
        
        // Do the following when the network request comes back successfully:
        // Update tableView data source
        self.collectionView.reloadData()
        refreshControl.endRefreshing()
    }
        
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! FlixDetailViewController
        detailViewController.movie = movie
    }
}