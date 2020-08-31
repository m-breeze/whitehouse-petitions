//
//  ViewController.swift
//  WhitehousePetitions
//
//  Created by Marina Khort on 16.08.2020.
//  Copyright © 2020 Marina Khort. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

	var petitions = [Petition]()
	var filteredPetitions = [Petition]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		performSelector(inBackground: #selector(fetchJSON), with: nil)
				
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(creditsTapped))
		let filter = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterTapped))
		let reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadTapped))
		navigationItem.leftBarButtonItems = [reload, filter]
		
//		let urlString: String
//
//		if navigationController?.tabBarItem.tag == 0 {
//			urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
//		} else {
//			urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
//		}
//
//		DispatchQueue.global(qos: .userInitiated).async {
//			if let url = URL(string: urlString) {
//				if let data = try? Data(contentsOf: url) {
//					self.parse(json: data)
//					return
//				}
//			}
			//make showError() on the background, but...(look on this method below)
//			self.showError()
//		}
	}
	
	@objc func fetchJSON() {
		let urlString: String
		
		if navigationController?.tabBarItem.tag == 0 {
			urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
		} else {
			urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
		}
		
		if let url = URL(string: urlString) {
			if let data = try? Data(contentsOf: url) {
				self.parse(json: data)
				return
			}
		}
	}
	
	func parse(json: Data) {
		let decoder = JSONDecoder()
		
		if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
			petitions = jsonPetitions.results
			filteredPetitions = petitions
			//we have to parse on the background, but reload data must be on the main thread as well as showing error alert
			tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
		} else {
			performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredPetitions.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let petition = filteredPetitions[indexPath.row]
		cell.textLabel?.text = petition.title
		cell.detailTextLabel?.text = petition.body
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = DetailViewController()
		vc.detailItem = filteredPetitions[indexPath.row]
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc func creditsTapped() {
		let ac = UIAlertController(title: "", message: "The data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Ok", style: .default))
		present(ac, animated: true)
	}
	
	@objc func filterTapped() {
		let ac = UIAlertController(title: "", message: "What do you want to find?", preferredStyle: .alert)
		ac.addTextField()
		
		let filterAction = UIAlertAction(title: "Filter", style: .default) { [weak self, weak ac] action in
			guard let text = ac?.textFields?[0].text else { return }
			self?.filter(text)
		}
		ac.addAction(filterAction)
		present(ac, animated: true)
	}
	
	@objc func reloadTapped() {
		filteredPetitions = petitions
		tableView.reloadData()
	}
	
	
	func filter(_ text: String) {
		filteredPetitions = filteredPetitions.filter {$0.body.contains(text)}
		tableView.reloadData()
		return
	}
	
	
	@objc func showError() {
		let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Ok", style: .default))
		present(ac, animated: true)
	}
}

