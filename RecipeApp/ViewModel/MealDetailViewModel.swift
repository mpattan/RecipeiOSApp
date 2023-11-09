//
//  MealDetailViewModel.swift
//  RecipeApp
//
//  Created by Sarfraz Khan on 06/11/23.
//


import Foundation
import Combine

struct MealDetailResponse: Decodable {
    fileprivate let meals: [MealDetail]
}

class MealDetailViewModel: ObservableObject {
    @Published var meal: MealDetail?
    @Published private var isLoading = false
    @Published var isError = false
    
    private var cancellables: Set<AnyCancellable> = []

    func fetchMealDetails(mealID: String) {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(mealID)") else {
            return
        }

        isLoading = true

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MealDetailResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main) // Ensure updates occur on the main thread
            .sink { completion in
                if case .failure(let error) = completion {
                    self.isError = true
                    print(error)
                }
            } receiveValue: { response in
                self.isLoading = false
                self.meal = response.meals.first
            }
            .store(in: &cancellables)
    }
}
