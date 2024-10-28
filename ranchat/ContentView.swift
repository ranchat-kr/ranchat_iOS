//
//  ContentView.swift
//  ranchat
//
//  Created by 김견 on 9/8/24.
//

import SwiftUI

struct ContentView: View {

    init () {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
}
