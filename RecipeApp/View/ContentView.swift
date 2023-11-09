//
//  ContentView.swift
//  RecipeApp
//
//  Created by Sarfraz Khan on 06/11/23.
//
//  This is the homepage of the application

import SwiftUI

struct ContentView: View {
    @ObservedObject private var mealsViewModel = MealsViewModel()
    @State private var isDarkMode = false
    @State private var searchText = ""
    @State private var isTextSizeIncreased = false

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: homePageConstants.cardMinSize))]
    }
    
    // This variable stores the filtered meals, required for the search functionality
    var filteredMeals: [Meal] {
        if searchText.isEmpty {
            return mealsViewModel.meals
        } else {
            let filteredMeals = mealsViewModel.meals.filter { $0.strMeal.lowercased().contains(searchText.lowercased()) }
            return filteredMeals
        }
    }
    
    // To update the text size when the zoom is toggled
    var textSize: CGFloat {
        isTextSizeIncreased ? homePageConstants.zoomInTextSize : homePageConstants.zoomOutTextSize
    }

    var body: some View {
        NavigationView {
            ScrollView {
                // If there are no results found for the given search string, a string is displayed to communicate to the user
                if filteredMeals.isEmpty {
                    Text(homePageConstants.noRecipe)
                        .font(Font.custom(homePageConstants.customFont, size: textSize))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: homePageConstants.cardSpace) {
                        ForEach(filteredMeals) { meal in
                            MealCardView(meal: meal, textSize: textSize)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(homePageConstants.navigationText)
            .font(Font.custom(homePageConstants.customFont, size: homePageConstants.navigationTitle))
            .toolbar {
                // The Zoom toggle
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isTextSizeIncreased.toggle()
                    }) {
                        Image(systemName: isTextSizeIncreased ? icons.zoomOut : icons.zoomIn)
                    }
                }
                // The Light and Dark mode toggle
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? icons.lightMode : icons.darkMode)
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .searchable(text: $searchText, prompt: homePageConstants.search)
            .font(Font.custom(homePageConstants.customFont, size: textSize))
        }
        // Making the API call to fetch all the available recipes
        .onAppear {
            mealsViewModel.fetchDessertMeals()
        }
    }
}

// Constants used on this view
private struct homePageConstants {
    static let cardMinSize:CGFloat = 200
    static let zoomOutTextSize:CGFloat = 16
    static let zoomInTextSize:CGFloat = 24
    static let navigationTitle: CGFloat = 30
    static let cardSpace: CGFloat = 16
    static let customFont: String = "AmericanTypewriter"
    static let noRecipe: String = "No Recipe Found"
    static let navigationText: String = "Dessert Recipes"
    static let search: String = "Search by Name"
}

// Struct for the icons used on this view
private struct icons {
    static let lightMode = "sun.max.fill"
    static let darkMode = "moon.fill"
    static let zoomOut = "minus.magnifyingglass"
    static let zoomIn = "plus.magnifyingglass"
}
