//
//  ViewController.swift
//  CampusPark
//
//  Created by Justin Ching on 1/24/22.
//

import UIKit
import MapKit

class ViewController: UIViewController,UISearchResultsUpdating {
    

    let mapView = MKMapView()
    
    let searchVC = UISearchController(searchResultsController: ResultsViewController())
        
    override func viewDidLoad() { //lol idk what this does
        super.viewDidLoad()
        title = "Maps"
        view.addSubview(mapView)
        searchVC.searchBar.backgroundColor = .secondarySystemBackground //searchbar color
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        // Do any additional setup after loading the view.
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
//Rmeove all map pins
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates,span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true) //how far to zoom

//Add pins
    }
}

