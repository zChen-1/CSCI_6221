//
//  ViewFoundItems.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/11.
//

import SwiftUI
import UIKit
import CloudKit
import Supabase

struct ItemSupa: Codable {
//    let item_id: Int
    let item_name: String
    let category: String
    let reported_by: UUID?
    let is_active: Bool
    let item_description: String
    let location: String
    let item_image: String?
}

struct ViewFoundItems: View {

    
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://trzpyocnxmimgvauphjm.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyenB5b2NueG1pbWd2YXVwaGptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE3ODgwNzcsImV4cCI6MjA0NzM2NDA3N30.LHu4FCxWJFgx-iDJXEjoGmtIi7PtfJcZA2GkJ1gy1JQ"
    )
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var navigateToUserView: Bool
    @StateObject private var authService = AuthService.shared
    
    @State private var selectedLocation: String = "Select a location"
    @State private var selectedItemType: String = "Select an item type"
    @State private var description: String = ""
    @State private var message: String = ""
    @State private var showAlert = false
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isCamera = false
    @State private var navigateToHome = false

    let itemTypes: [String] = ["Select an item type", "Book", "Laptop", "Bag", "Phone", "ID", "Key", "Wallet", "Earphones", "Other"]
    let locations: [String] = ["Select a location", "The George Washington University Hospital", "The School of Engineering and Applied Science (SEAS)", "The Columbian College of Arts and Sciences (CCAS)"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Report a Finding")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    
                    pickerField(title: "What did you find?", selection: $selectedItemType, options: itemTypes)
                    pickerField(title: "Where did you find it?", selection: $selectedLocation, options: locations)
                    descriptionField(title: "More details about the item", text: $description)
                    
                    Spacer()
                    
                    VStack {
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
                .navigationDestination(isPresented: $navigateToHome) {
                    UserUIView(navigateToChatView: $navigateToHome, isLoggedIn: $navigateToHome) // Replace with your home page view
                            }
                .padding()
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $selectedImage, isCamera: $isCamera) // Use ImagePicker when adding images
                }.alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Success"),
                        message: Text(message),
                        dismissButton: .default(Text("OK"))
                    )
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

//    func saveLostItemsToCloudKit(lostItems: [LostItems]) {
//        let container = CKContainer.default()
//        let privateDatabase = container.privateCloudDatabase
//
//        for item in lostItems {
//            let record = CKRecord(recordType: "LostItem")
//            record["name"] = item.name as CKRecordValue
//            record["itemType"] = item.itemType as CKRecordValue
//            record["itemDescription"] = item.itemDescription as CKRecordValue
//            record["locationID"] = item.locationID as CKRecordValue
//            record["imageName"] = item.imageName as CKRecordValue
//
//            privateDatabase.save(record) { (record, error) in
//                if let error = error {
//                    print("Error saving record: \(error)")
//                } else {
//                    print("Lost Item saved successfully: \(String(describing: record))")
//                }
//            }
//        }
//    }
    
    private func isValidInputs() -> Bool {
        
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
    
//    // Email format validation,
//    func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}"
//        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
//        return emailTest.evaluate(with: email)
//    }
    
    // Handle Submit to save, connect to a DB later!!!
    private func handleSubmit() {
        // send data to a server and save it
        //saveLostItemsToCloudKit(lostItems)
        print("Location: \(selectedLocation), Item Type: \(selectedItemType), Description: \(description)")
        Task {
                    do {
                        let savedItem = try await saveItem()
                        print("Item saved successfully: \(savedItem)")
                        message = "Item added successfully!"
                        showAlert = true
                        navigateToHome = true
                    } catch {
                        print("Error saving item: \(error)")
                    }
                }
        presentationMode.wrappedValue.dismiss()
    }
    
    func saveItem() async throws -> ItemSupa {
        // 1. Upload image if exists
        var imageUrl: String? = nil
        if let image = selectedImage,
                   let imageData = image.jpegData(compressionQuality: 0.7) {
                    imageUrl = try await uploadImage(imageData: imageData)
                }
        
            // 2. Create item record
            let newItem = ItemSupa(
//                id: UUID(),
                item_name: selectedItemType,
                category: "Found",
                reported_by: authService.currentUser?.id,
                is_active: true,
                item_description: description,
                location: selectedLocation,
                item_image: imageUrl
                
            )
            
            // 3. Insert item into Supabase
            return try await supabase
                .from("items")
                .insert(newItem)
                .select()
                .single().execute().value
            
        }
    
    private func uploadImage(imageData: Data) async throws -> String {
            let fileName = "\(selectedItemType).jpg" // Use the ID as the file name
            let filePath = "\(fileName)"
        
            // Upload image to Supabase storage
            try await supabase
                .storage
                .from("images")
                .upload(
                    path: filePath,
                    file: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // Generate public URL
            let publicUrl = try supabase
                .storage
                .from("images")
                .getPublicURL(path: filePath)
            
            return publicUrl.absoluteString
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
