//
//  MealDetailView.swift
//  RecipeApp
//
//  Created by Sarfraz Khan on 06/11/23.
//
//  This is the view for instructions of each recipe

import SwiftUI

struct MealDetailView: View {
    private let mealID: String
    private let textSize: CGFloat
    @ObservedObject var viewModel: MealDetailViewModel
    @State private var showErrorAlert = false
    @State private var isShowingContent = false
    @Environment(\.colorScheme) var colorScheme // Access the color scheme
    @State private var isIngredientsCollapsed = false
    @State private var isTextSizeIncreased = false

    init(mealID: String, textSize: CGFloat) {
        self.mealID = mealID
        self.textSize = textSize
        viewModel = MealDetailViewModel()
    }

    var body: some View {
        
        // Displaying an error pop-up when the fetch fails
        if viewModel.isError {
            Text(mealDetailConstants.failedFetch)
                .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                .padding()
                .foregroundColor(.red)
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text(mealDetailConstants.errorText),
                        message: Text(mealDetailConstants.failedFetch)
                            .font(Font.custom(mealDetailConstants.customFont, size: textSize)),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .onAppear {
                    withAnimation {
                        showErrorAlert = true
                    }
                }
        } else {
            
            // When the fetch is successful, displaying the list of meals in a vertical stack
            ScrollView {
                VStack(alignment: .leading, spacing: mealDetailConstants.spacing) {
                    
                    Text(viewModel.meal?.strMeal ?? mealDetailConstants.defaultText)
                        .font(Font.custom(mealDetailConstants.customFont, size: mealDetailConstants.titleSize))
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(.blue)
                        .onAppear {
                            withAnimation {
                                isShowingContent = true
                            }
                        }
                    
                    // Fetches the images for each recipe from its corresponding strMealThumb property
                    if let imageURL = URL(string: viewModel.meal?.strMealThumb ?? mealDetailConstants.defaultText) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: mealDetailConstants.imageMaxHeight) // Adjust the height as needed
                                .clipShape(Circle()) // Display the image in a circle
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    // Displaying instructions separted by "." on a new line
                    Text(mealDetailLabels.instructions)
                        .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(.green)
                    if let instructions = viewModel.meal?.formattedInstructions {
                        ForEach(instructions, id: \.self) { instruction in
                            VStack(alignment: .leading) {
                                Text(instruction)
                                    .padding(.horizontal)
                                    .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                                Divider() // Add a horizontal line under each instruction
                            }
                        }
                    }
                    
                    // Adding a URL to the recipe's corresponding YouTube video from the strYoutube property
                    Button(action: {
                        if let youtubeURL = URL(string: viewModel.meal?.strYoutube ?? mealDetailConstants.defaultText) {
                            UIApplication.shared.open(youtubeURL)
                        }
                    }) {
                        Text(mealDetailLabels.youtubeVideo)
                            .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                            .bold()
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                    // Displaying a list of ingredients along with their correspnding measurements in a collapsible list
                    DisclosureGroup(mealDetailLabels.ingredientsList, isExpanded: $isIngredientsCollapsed) {
                        ForEach(Array(zip(viewModel.meal?.ingredients ?? [], viewModel.meal?.measurements ?? []).filter { !$0.0.isEmpty }), id: \.0) { (ingredient, measurement) in
                            HStack {
                                Text(ingredient.capitalized)
                                    .bold()
                                    .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                                Spacer()
                                Text(" \(measurement.replacingOccurrences(of: "/", with: " / "))")
                                    .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                                    .bold()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                    .bold()
                    .padding(.horizontal)
                    
                    // Displaying the region of a recipe
                    HStack {
                        Text(mealDetailLabels.region)
                            .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                            .bold()
                            .padding(.horizontal)
                            .foregroundColor(.green)
                        Text(viewModel.meal?.strArea ?? mealDetailConstants.unknownText)
                            .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                            .padding(.horizontal)
                    }
                    
                    // Displaying the tags of a recipe when available, if unavailable, this will be hidden
                    if let tags = viewModel.meal?.strTags, !tags.isEmpty {
                        HStack {
                            Text(mealDetailLabels.tags)
                                .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                                .bold()
                                .padding(.horizontal)
                                .foregroundColor(.green)
                            Text(tags)
                                .font(Font.custom(mealDetailConstants.customFont, size: textSize))
                                .padding(.horizontal)
                        }
                    }
                }
            }

            // Making the API call to hit the given endpoint to fetch the meal details
            .onAppear {
                viewModel.fetchMealDetails(mealID: mealID)
            }
            .navigationTitle(mealDetailLabels.navigationTitle)
            .background(colorScheme == .dark ? Color.black : Color.white) // Use colorScheme to set the background color
            .foregroundColor(colorScheme == .dark ? .white : .black) // Use colorScheme to set text color
        }
    }
}

// Struct for the constants of MealDetailView
private struct mealDetailConstants {
    static let zoomInTextSize: CGFloat = 24
    static let zoomOutTextSize: CGFloat = 16
    static let customFont: String = "AmericanTypewriter"
    static let failedFetch: String = "Failed to fetch meal details, Please try again later."
    static let spacing: CGFloat = 16
    static let titleSize: CGFloat = 30
    static let imageMaxHeight: CGFloat = 300
    static let defaultText: String = ""
    static let unknownText: String = "Unknown"
    static let errorText: String = "Error"
}

// Struct for the labels constants in this view
private struct mealDetailLabels {
    static let instructions: String = "Instructions:"
    static let youtubeVideo: String = "Watch Video on YouTube ->"
    static let ingredientsList: String = "List of Ingredients"
    static let region: String = "Region:"
    static let tags: String = "Tags:"
    static let navigationTitle: String = "Meal Details"
}
