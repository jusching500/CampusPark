//
//  ViewController.swift
//  CampusPark
//
//  Created by Justin Ching on 1/24/22.
//
import SideMenu
import UIKit
import MapKit

class ViewController: UIViewController,UISearchResultsUpdating {
    
    var menu: SideMenuNavigationController?
    
    let mapView = MKMapView()
    
    let searchVC = UISearchController(searchResultsController: ResultsViewController())
        
    override func viewDidLoad() { //lol idk what this does
        //sidemenu stuff
        menu = SideMenuNavigationController(rootViewController: MenuListController())
        //|^
        
        super.viewDidLoad()
        title = "Maps"
        view.addSubview(mapView)
        searchVC.searchBar.backgroundColor = .secondarySystemBackground //searchbar color
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        // Do any additional setup after loading the view.
    }
    //menu button
    @IBAction func didTapMenu(){
        present(menu!,animated: true)
        menu?.setNavigationBarHidden(true, animated: false)
        menu?.leftSide = true //needed to make it left
        
        SideMenuManager.default.leftMenuNavigationController = menu //might not need one of these two lines
        SideMenuManager.default.addPanGestureToPresent(toView: self.view) //needed to make it left
    }
    
    override func viewDidLayoutSubviews() { //lauout
        super.viewDidLayoutSubviews() 
        mapView.frame = view.bounds //how big the map screen is 
    }

    func updateSearchResults(for searchController: UISearchController) { // this connects to googleplacesmanager
        guard let query = searchController.searchBar.text,
            !query.trimmingCharacters(in: .whitespaces).isEmpty,
            let resultsVC = searchController.searchResultsController as? ResultsViewController
            else { //so that the query doesn't do anything when there is just whitespace in bar
            return
        }
        
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in // communicate with api if not not the case above
            switch result {
            case .success(let places):
                print(places)
                DispatchQueue.main.async { //results controller to view it
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }

        }
        
    }

}

extension ViewController: ResultsViewControllerDelegate{
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true, completion: nil)
//Rmeove all map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        //add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates,span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true) //how far to zoom

//Add pins
    }
}

class MenuListController: UITableViewController {
    var items = ["First", "Second", "Third"]
    let darkColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = darkColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = darkColor
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

