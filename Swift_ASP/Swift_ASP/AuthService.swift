//
//  AuthService.swift
//  Swift_ASP
//
//  Created by Samank Gupta on 21/11/24.
//

import Foundation
import Supabase

struct User: Codable {
    let id: UUID
    let email: String
    let name: String
}

class AuthService: ObservableObject {
    // Singleton instance
    static let shared = AuthService()
    
    private let supabase: SupabaseClient
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private init() {
        supabase = SupabaseClient(
            supabaseURL: URL(string: "https://trzpyocnxmimgvauphjm.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyenB5b2NueG1pbWd2YXVwaGptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE3ODgwNzcsImV4cCI6MjA0NzM2NDA3N30.LHu4FCxWJFgx-iDJXEjoGmtIi7PtfJcZA2GkJ1gy1JQ"
        )
        
        // Check initial authentication state
        Task {
            await restoreSession()
        }
    }
    
    // Supabase client accessor for other classes
    var client: SupabaseClient {
        return supabase
    }
    
    // Check if user is logged in
    func checkAuthStatus() async -> Bool {
        do {
            let session = try await supabase.auth.session
            return session.user.id != nil
        } catch {
            return false
        }
    }
    
    // Login method
    func login(email: String, password: String) async throws -> User {
        do {
            let authResponse = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            guard let user = try await fetchUserDetails(userId: authResponse.user.id) else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            return user
        } catch {
            print("Login error: \(error)")
            throw error
        }
    }
    
    // Fetch user details from custom users table
    private func fetchUserDetails(userId: UUID) async throws -> User? {
        return try await supabase
            .from("users")
            .select()
            .eq("id", value: userId)
            .single().execute().value
        
        
    }
    
    // Restore session if exists
    func restoreSession() async {
        do {
            let session = try await supabase.auth.session
            
            if let user = try await fetchUserDetails(userId: session.user.id) {
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
    }
    
    // Logout method
    func logout() async throws {
        do {
            try await supabase.auth.signOut()
            
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        } catch {
            print("Logout error: \(error)")
            throw error
        }
    }
}
