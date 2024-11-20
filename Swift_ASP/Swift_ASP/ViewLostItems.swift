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
    @State private var email: String = ""
    @State private var confirmEmail: String = ""
    @State private var selectedLocation: String = "Select a location"
    @State private var selectedItemType: String = "Select an item type"
    @State private var description: String = ""
    
    let itemTypes: [String] = ["Select an item type", "Book", "Journal", "Magazine", "Article", "ID", "Key", "Other"]
    let locations: [String] = ["Select a location", "The George Washington University Hospital", "The School of Engineering and Applied Science (SEAS)", "The Columbian College of Arts and Sciences (CCAS)"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Report a Lost Item")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
                
                inputField(title: "Enter your Email Address", text: $email)
                inputField(title: "Confirm your Email Address", text: $confirmEmail)
                pickerField(title: "Where did you find it?", selection: $selectedLocation, options: locations)
                pickerField(title: "What is that?", selection: $selectedItemType, options: itemTypes)
                descriptionField(title: "More details", text: $description)
                
                Spacer()
                Button(action: { navigateToLostView.toggle() }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .navigationTitle("Report Lost Item")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Image("GW color")
                    .resizable()
                    .scaledToFill()
                    .clipped()
            )
            bottomToolbar
        }
    }
    
    // Bottom toolbar
    private var bottomToolbar: some View {
            HStack {
                // Chat button
                Button(action: { print("Chat Action") }) {
                    Label("Chat", systemImage: "message.fill")
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()

                Button(action: { print("Homepage Action") }) {
                    Label("", systemImage: "house.fill")
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()

                // Profile button
                Button(action: { print("Profile Action") }) {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .frame(height: 60)
            .background(Color.white)
            .shadow(radius: 5)
    }
    
    private func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            TextField(title, text: text)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    private func descriptionField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextEditor(text: text)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .frame(height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
    
    private func pickerField(title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .frame(width: 370)
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
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
