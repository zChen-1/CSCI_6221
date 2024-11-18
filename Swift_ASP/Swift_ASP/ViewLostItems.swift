//
//  ViewLostItems.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/11.
//

import SwiftUI

// Model for Lost Item
struct LostItem: Identifiable {
    var id = UUID()
    var name: String
}

struct ViewLostItems: View {
    @State private var navigateToLostView: Bool = false
    @State private var lostItems: [LostItem] = [
        LostItem(name: "Laptop"),
        LostItem(name: "Phone"),
        LostItem(name: "Wallet"),
        LostItem(name: "Keys"),
        LostItem(name: "Backpack"),
        LostItem(name: "Textbook"),
        LostItem(name: "ID Card"),
        LostItem(name: "Umbrella"),
        LostItem(name: "Gloves"),
        LostItem(name: "Headphones")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                headerView
                
                List(lostItems) { item in
                    NavigationLink(destination: LostItemDetailView(item: item)) {
                        Text(item.name)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Lost Items")
            }
            .background(
                Image("GW color")
                    .resizable()
                    .scaledToFill()
                    .clipped()
            )
        }
    }
    
    // Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                // Action for the dashboard
            }) {
                HStack {
                    Image(systemName: "person.crop.circle")
                    Text("My dashboard")
                }
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                print("Setting button works")
            }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                    Text("Setting")
                }
            }
            .foregroundColor(.white)
        }
        .padding()
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// Detail view for each lost item
struct LostItemDetailView: View {
    var item: LostItem
    
    var body: some View {
        VStack {
            Text(item.name)
                .font(.largeTitle)
                .padding()
            // Further details about the item can go here
            Text("Details about \(item.name) go here.")
                .padding()
            Spacer()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview Provider
#Preview {
    ViewLostItems()
}
