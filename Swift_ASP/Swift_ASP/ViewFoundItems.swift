//
//  ViewFoundItems.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/11.
//

import SwiftUI
import CoreData
import UIKit

struct ViewFoundItems: View {
    @State private var gwid: String = ""
    @State private var email: String = ""
    @State private var confirmEmail: String = ""
    @State private var selectedLocation: String = "Select a location"
    @State private var selectedItemType: String = "Select an item type"
    @State private var description: String = ""
    @State private var message: String = ""
    @State private var showAlert = false
    @State private var selectedImage: UIImage? // Variable to hold the selected image
    @State private var showingImagePicker = false // State for image picker
    @State private var isCamera = false // State to determine if camera or photo library is used
    
    // Define item types and locations
    let itemTypes: [String] = ["Select an item type", "Book", "Journal", "Magazine", "Article", "ID", "Key", "Other"]
    let locations: [String] = ["Select a location", "The George Washington University Hospital", "The School of Engineering and Applied Science (SEAS)", "The Columbian College of Arts and Sciences (CCAS)"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    headerView
                    
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
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            Button(action: {
                                showingImagePicker.toggle() // Show image picker
                            }) {
                                Text("Add Image")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .sheet(isPresented: $showingImagePicker) {
                                ImagePicker(image: $selectedImage, isCamera: $isCamera) // Use ImagePicker when adding images
                            }
                        }
                        
                        // Submit Button
                        Button("Submit") {
                            if email.isEmpty || !isValidEmail(email) {
                                message = "Something went wrong. Please check your email address."
                                showAlert = true
                            } else if email != confirmEmail || !isValidEmail(email) {
                                message = "The confirmed email address is inconsistent with the email address. Please check."
                                showAlert = true
                            } else if selectedLocation == "Select a location" {
                                message = "Please select a location."
                                showAlert = true
                            } else if selectedItemType == "Select an item type" {
                                message = "Please select an item type."
                                showAlert = true
                            } else {
                                handleSubmit()
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
                        .disabled(email.isEmpty || confirmEmail.isEmpty || selectedLocation == "Select a location" || selectedItemType == "Select an item type")
                    }
                }
                .padding()
                .background(
                    Image("GW color")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                )
            }
            .navigationTitle("Report Found Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Header View
    private var headerView: some View {
        HStack {
            Button(action: {
            // Dashboard action
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
    
    // Input Field
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
    
    // Picker Field
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
    
    // Email format validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    // Handle Submit
    private func handleSubmit() {
        print("Email: \(email), Location: \(selectedLocation), Item Type: \(selectedItemType), Description: \(description)")
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
        
        // Delegate method called when an image is selected
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage // Set the selected image
            }
            picker.dismiss(animated: true) // Dismiss the picker
        }
        
        // Delegate method called when the picker is cancelled
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) // Dismiss the picker
        }
    }
}

            // Preview Provider
struct ViewFoundItems_Previews: PreviewProvider {
    static var previews: some View {
        ViewFoundItems() // Preview the ViewFoundItems view
    }
}
