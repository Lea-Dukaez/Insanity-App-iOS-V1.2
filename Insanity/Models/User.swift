//
//  User.swift
//  Insanity
//
//  Created by Léa on 13/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import Foundation

struct User: Equatable {
    let pseudo: String
    let nameSearch: String
    let avatar: String
    let id: String
    var status: String = "null"
}
