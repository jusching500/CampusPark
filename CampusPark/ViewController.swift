//
//  ViewController.swift
//  CampusPark
//
//  Created by Justin Ching on 1/24/22.
//
import SideMenu
import UIKit
import MapKit

class ViewController: UIViewController,UISearchResultsUpdating,MenuControllerDelegate {
    
    private let settingsController = SettingsViewController()
    private let profileController = ProfileViewController()
    
    private var sideMenu: SideMenuNavigationController?
    
    let mapView = MKMapView()
    
    let searchVC = UISearchController(searchResultsController: ResultsViewController())
        
    override func viewDidLoad() { //lol idk what this does
        super.viewDidLoad()
        let menu = MenuController(with: ["Map","Profile","Settings"])
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        //sidemenu stuff
        menu.delegate = self
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view) //needed to make//might not need one of these two lines

        //|^
        
        title = "Maps"
        view.addSubview(mapView)
        searchVC.searchBar.backgroundColor = .secondarySystemBackground //searchbar color
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        // Do any additional setup after loading the view.
        addchildControllers()
    }
    //menu button
    //adding the pages foor the sidemneu
    private func addchildControllers(){
        addChild(self.settingsController)
        addChild(self.profileController)
        view.addSubview(settingsController.view)
        view.addSubview(profileController.view)
        settingsController.view.frame = view.bounds
        profileController.view.frame = view.bounds
        
        settingsController.didMove(toParent: self)
        profileController.didMove(toParent: self)
        
        settingsController.view.isHidden = true
        profileController.view.isHidden = true

    }
    
    @IBAction func didTapMenu(){
        present(sideMenu!,animated: true)

    }
    
    func didSelectMenuItem(named: String) {
        sideMenu?.dismiss(animated: true, completion: { [weak self] in
            if named == "Map"{
                self?.settingsController.view.isHidden = true
                self?.profileController.view.isHidden = true
                self?.view.backgroundColor = .white
            }
            else if named == "Profile"{
                self?.settingsController.view.isHidtden = true
                self?.profileController.view.isHidden = false
                self?.view.backgroundColor = .red
            }
            else if named == "Settings"{
                self?.settingsController.view.isHidden = true
                self?.profileController.view.isHidden = false
                self?.view.backgroundColor = .green
            }
        })
        
    }
    
    override func viewDidLayoutSubviews() { //lauout
        super.viewDidLayoutSubviews() 
        mapView.frame = CGRect(x:0,y:view.safeAreaInsets.top,width: view.frame.size.width, height: view.frame.size.height - view.safeAreaInsets.top) //how big the map screen is
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

