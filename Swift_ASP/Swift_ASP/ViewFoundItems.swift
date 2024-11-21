//
//  ViewFoundItems.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/11.
//

import SwiftUI
import UIKit
import CloudKit

struct ViewFoundItems: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var navigateToUserView: Bool
    @State private var email: String = ""
    @State private var confirmEmail: String = ""
    @State private var selectedLocation: String = "Select a location"
    @State private var selectedItemType: String = "Select an item type"
    @State private var description: String = ""
    @State private var message: String = ""
    @State private var showAlert = false
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isCamera = false
    
    let itemTypes: [String] = ["Select an item type", "Book", "Journal", "Magazine", "Article", "ID", "Key", "Other"]
    let locations: [String] = ["Select a location", "The George Washington University Hospital", "The School of Engineering and Applied Science (SEAS)", "The Columbian College of Arts and Sciences (CCAS)"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Report a Finding")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                    
                    inputField(title: "Enter your Email Address", text: $email)
                    inputField(title: "Confirm your Email Address", text: $confirmEmail)
                    pickerField(title: "Where did you find it?", selection: $selectedLocation, options: locations)
                    pickerField(title: "What is that?", selection: $selectedItemType, options: itemTypes)
                    descriptionField(title: "More details", text: $description)
                    
                    Spacer()
                    
                    HStack {
                        if let selectedImage = selectedImage {
                            Button(action: {
                                showingImagePicker.toggle() // Show image picker again
                            }) {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            }
                            .padding()
                        } else {
                            Button(action: {
                                showingImagePicker.toggle() // Show image picker
                            }) {
                                Text("Add Image")
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Button("Submit") {
                            if isValidInputs() {
                                handleSubmit()
                                //message = "Item reported successfully!"
                                //navigateToUserView = true // Navigate back after submission
                            } else {
                                showAlert = true
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Oops"),
                                message: Text(message),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    }
                    .padding(.top, 20)
                }
                .padding()
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $selectedImage, isCamera: $isCamera) // Use ImagePicker when adding images
                }
            }
            .navigationTitle("Report Found Item")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Image("GW color")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(maxWidth: .infinity, maxHeight: .infinity))
            
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

                Button(action: { presentationMode.wrappedValue.dismiss() }) {
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

    func saveLostItemsToCloudKit(lostItems: [LostItems]) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase

        for item in lostItems {
            let record = CKRecord(recordType: "LostItem")
            record["name"] = item.name as CKRecordValue
            record["itemType"] = item.itemType as CKRecordValue
            record["itemDescription"] = item.itemDescription as CKRecordValue
            record["locationID"] = item.locationID as CKRecordValue
            record["imageName"] = item.imageName as CKRecordValue

            privateDatabase.save(record) { (record, error) in
                if let error = error {
                    print("Error saving record: \(error)")
                } else {
                    print("Lost Item saved successfully: \(String(describing: record))")
                }
            }
        }
    }
    
    private func isValidInputs() -> Bool {
        if email.isEmpty || !isValidEmail(email) {
            message = "Please enter a valid email address."
            return false
        }
        if email != confirmEmail {
            message = "Email and confirmation must match."
            return false
        }
        if selectedLocation == "Select a location" {
            message = "Please select a location."
            return false
        }
        if selectedItemType == "Select an item type" {
            message = "Please select an item type."
            return false
        }
        return true
    }
    
    // Email format validation,
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    // Handle Submit to save, connect to a DB later!!!
    private func handleSubmit() {
        // send data to a server and save it
        //saveLostItemsToCloudKit(lostItems)
        print("Email: \(email), Location: \(selectedLocation), Item Type: \(selectedItemType), Description: \(description)")
        presentationMode.wrappedValue.dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isCamera: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = isCamera ? .camera : .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // Set the selected image
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true) // Dismiss the picker
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) // Dismiss the picker
        }
    }
}

struct ViewFoundItems_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewFoundItems(navigateToUserView: .constant(false)) // Logged Out State
                .previewDisplayName("Report Found Item")
        }
    }
}
