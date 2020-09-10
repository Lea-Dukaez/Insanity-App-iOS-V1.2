//
//  Workout.swift
//  Insanity
//
//  Created by Léa on 25/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import Foundation
import Firebase

struct Workout {
    let userID: String
    let workoutID: String
    var workOutResult: [Double]
    let date: Timestamp
}
