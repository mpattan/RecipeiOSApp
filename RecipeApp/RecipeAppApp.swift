//
//  RecipeApp.swift
//  RecipeApp
//
//  Created by Sarfraz Khan on 06/11/23.
//

import SwiftUI

@main
struct RecipeApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
