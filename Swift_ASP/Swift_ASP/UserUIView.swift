//
//  UserUIView.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/9.
//

import SwiftUI

struct UserUIView: View {
    @State private var navigateToContentView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Map")
                    .font(.largeTitle)
                    .padding()
                
                // Add your map or other content here
                Spacer()
            }
            .background(
                Image("GW color") // Ensure this image exists in your asset catalog
                    .resizable()
                    .scaledToFill()
                    .clipped()
            )
            //.navigationTitle("User Dashboard") // Set title for UserUIView
            //.navigationBarTitleDisplayMode(.inline) // Optional: Set title display mode
            
            // Toolbar for navigation buttons
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    
                    Button(action: {
                        print("Logout tapped")
                    }) {
                        HStack {
                            Image(systemName: "figure.walk.departure")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Logout")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
    }
}

struct UserUIView_Previews: PreviewProvider {
    static var previews: some View {
        UserUIView()
    }
}
