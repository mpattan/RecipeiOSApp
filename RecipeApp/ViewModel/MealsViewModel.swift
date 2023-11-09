//
//  MealsViewModel.swift
//  RecipeApp
//
//  Created by Sarfraz Khan on 06/11/23.
//

import Foundation

struct MealsResponse: Decodable {
    fileprivate let meals: [Meal]
    
    enum CodingKeys: String, CodingKey {
        case meals = "meals"
    }

    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            meals = try container.decode([Meal].self, forKey: .meals)
        }
}

class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published private var isLoading = false
    @Published private var isError = false
    private let categoryURL = "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert"

    func fetchDessertMeals() {
        guard let url = URL(string: categoryURL) else {
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(MealsResponse.self, from: data)
                    
                    DispatchQueue.main.async { // Update on the main thread
                        self.isLoading = false
                        self.meals = response.meals
                    }
                } catch {
                    DispatchQueue.main.async { // Update on the main thread
                        self.isError = true
                    }
                    print(error)
                }
            } else if let error = error {
                DispatchQueue.main.async { // Update on the main thread
                    self.isError = true
                }
                print(error)
            }
        }.resume()
    }
    
    func filteredMeals(searchText: String) -> [Meal] {
            if searchText.isEmpty {
                return meals
            } else {
                return meals.filter { $0.strMeal.lowercased().contains(searchText.lowercased())
                }
            }
    }
}
