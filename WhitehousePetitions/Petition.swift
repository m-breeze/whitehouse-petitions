//
//  Petition.swift
//  WhitehousePetitions
//
//  Created by Marina Khort on 18.08.2020.
//  Copyright © 2020 Marina Khort. All rights reserved.
//

import Foundation

struct Petition: Codable {
	var title: String
	var body: String
	var signatureCount: Int
}
