//
//  MealCardView.swift
//  RecipeApp
//
//  Created by Sarfraz Khan on 08/11/23.
//

import SwiftUI

struct MealCardView: View {
    let meal: Meal
    let textSize: CGFloat
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: MealDetailView(mealID: meal.idMeal, textSize: textSize)) {
            VStack(spacing: cardConstants.contentSpacing) {
                AsyncImage(url: URL(string: meal.strMealThumb) ?? URL(string: cardConstants.defaultText))
                { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: cardConstants.imageHeight)
                        .clipped()
                        .cornerRadius(cardConstants.cornerRadius)
                } placeholder: {
                    ProgressView()
                        .frame(height: cardConstants.loadingView)
                }

                Text(meal.strMeal.capitalized)
                    .font(Font.custom(cardConstants.customFont, size: textSize))
                    .bold()
                    .padding()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(cardConstants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cardConstants.cornerRadius)
                    .stroke(Color.primary, lineWidth: cardConstants.shadowLine) // Add a border
            )
            .shadow(radius: cardConstants.shadowDepth)
        }
        .buttonStyle(PlainButtonStyle()) // Use a plain button style
    }
}

private struct cardConstants {
    static let imageHeight: CGFloat = 150
    static let cornerRadius: CGFloat = 10
    static let loadingView: CGFloat = 150
    static let shadowDepth: CGFloat = 3
    static let shadowLine: CGFloat = 1
    static let contentSpacing: CGFloat = 8
    static let customFont: String = "AmericanTypewriter"
    static let defaultText: String = ""
}
