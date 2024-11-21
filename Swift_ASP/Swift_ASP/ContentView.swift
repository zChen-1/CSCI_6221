//
//  ContentView.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/10/17.
//

import SwiftUI
import CoreData
import WebKit
import Supabase

struct ContentView: View {
    @State private var isLoggedIn: Bool = false // Manage login state
    @State private var navigateToChatView: Bool = false // Track navigation to chat view
    var body: some View {
        NavigationStack {
            if isLoggedIn {
                UserUIView(navigateToChatView: $navigateToChatView, isLoggedIn: $isLoggedIn)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var showAlert = false
    @State private var showRegisterAlert = false
    @State private var navigateToUserView: Bool = false
    @Binding var isLoggedIn: Bool
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, password
    }

    var body: some View {
        VStack {
            Text("Lost and Found Map")
                .bold()
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(
                    Image("GW color")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            Image("gwu logo")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(contentMode: .fit)
                
            // Login box (Username)
            HStack {
                TextField("GWID", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .focused($focusedField, equals: .username)
                Text("@gwu.edu")
                    .padding()
                    .foregroundColor(.black)
            }
            .onAppear {
                        // Automatically focus the username field when the view appears
                        focusedField = .username
                    }
            
            // Login box (Password)
            HStack {
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity).focused($focusedField, equals: .password)
            }
            .onAppear {
                        // Automatically focus the username field when the view appears
                focusedField = .password
                    }
            
            VStack {
                
                
                // Login Button
                Button("Login") {
                    if username.isEmpty || password.isEmpty {
                        message = "Please enter both GWID and password."
                        showAlert = true
                    } else if username.isEmpty {
                        message = "Please enter your GWID."
                        showAlert = true
                    } else if password.isEmpty {
                        message = "Please enter password."
                        showAlert = true
                    }
                    // For test version
                    else if username == "g123456789" || password == "123456789" {
                        //navigateToUserView = true
                        isLoggedIn = true
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Oops"),
                        message: Text(message),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding()
                
                // Register Button
                Button("Register") {
                    message = "You must have your GWID to Login. Do you want to find your GWID?"
                    showRegisterAlert = true
                }
                .alert(isPresented: $showRegisterAlert) {
                    Alert(
                        title: Text("Oops"),
                        message: Text(message),
                        primaryButton: .destructive(Text("Yes")) {
                            // Open the browser with the GWU website
                            if let url = URL(string: "https://it.gwu.edu/gweb") {
                                UIApplication.shared.open(url)
                            }
                        },
                        secondaryButton: .cancel(Text("No"))
                    )
                }
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
