//
//  Meal.swift
//  RecipeApp
//
//  Created by Sarfraz Khan on 06/11/23.
//

import Foundation

struct Meal: Identifiable, Decodable {
    
    let strMeal: String
    let idMeal: String
    let strMealThumb: String
    var id: String {
        return idMeal
    }
}
