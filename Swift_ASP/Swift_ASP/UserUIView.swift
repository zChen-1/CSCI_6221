//
//  UserUIView.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/9.
//

import SwiftUI
import MapKit

// Data model for representing a location
struct Location: Identifiable {
    var id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var locationID: Int
}

// Data model for representing a lost item
struct LostItems: Identifiable {
    var id = UUID()
    var name: String
    var itemType: String
    var itemDescription: String
    var locationID: Int
    var imageName: String
}

struct UserUIView: View {
    // State variables for navigation and selection
    @State private var navigateToLostView = false
    @State private var navigateToSettingView = false
    @State private var navigateToDashboardView = false
    @State private var navigateToFoundView = false
    @State private var showItemAlert = false
    @State private var selectedItem: LostItems? = nil
    @State private var selectedLocationID: Int? = nil
    
    
    @Binding var isLoggedIn: Bool
    
    // Initial region for the displayed map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.899902, longitude: -77.047201),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    )
    
    // Predefined locations to be annotated on the map
    let locations = [
        Location(name: "The George Washington University Hospital", coordinate: CLLocationCoordinate2D(latitude: 38.901253, longitude: -77.050670), locationID: 1),
        Location(name: "The School of Engineering and Applied Science (SEAS)", coordinate: CLLocationCoordinate2D(latitude: 38.899934, longitude: -77.049120), locationID: 2),
        Location(name: "The Columbian College of Arts and Sciences (CCAS)", coordinate: CLLocationCoordinate2D(latitude: 38.900169, longitude: -77.047080), locationID: 3)
    ]
    
    // Example data for lost items
    let lostItemsData: [LostItems] = [
        LostItems(name: "Laptop", itemType: "Electronics", itemDescription: "A silver laptop found near SEAS", locationID: 1, imageName: "No_Image_Available"),
        LostItems(name: "Phone", itemType: "Electronics", itemDescription: "An iPhone found at CCAS", locationID: 2, imageName: "No_Image_Available"),
        LostItems(name: "Book", itemType: "Literature", itemDescription: "A textbook found at GW Hospital", locationID: 3, imageName: "No_Image_Available"),
        LostItems(name: "Pen", itemType: "Office Supplies", itemDescription: "A black pen found at GW Hospital", locationID: 2, imageName: "No_Image_Available")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                headerView
                
                // Map view with annotations
                Map(coordinateRegion: $region, annotationItems: locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        Button(action: {
                            selectLocation(location)
                        }) {
                            Text("\(location.locationID)")
                                .fontWeight(.bold)
                                .padding(6)
                                .background(Color.blue.opacity(0.7))
                                .cornerRadius(100)
                                .foregroundColor(.white)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .frame(height: 400)
                
                if let id = selectedLocationID {
                    createListOverlay(locationID: id)
                }
                
                actionButtons
                
                Spacer()
            }
            .background(
                Image("GW color")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        HStack {
                            Image(systemName: "figure.walk.arrival")
                            Text("Logout")
                        }
                        .font(.headline)
                    }
                }
            }
            
            // Navigation links to different views
            NavigationLink(destination: ViewFoundItems(), isActive: $navigateToFoundView) { EmptyView() }
            NavigationLink(destination: ViewLostItems(), isActive: $navigateToLostView) { EmptyView() }
            NavigationLink(destination: SettingView(), isActive: $navigateToSettingView) { EmptyView() }
            NavigationLink(destination: DB_View(), isActive: $navigateToDashboardView) { EmptyView() }
        }
    }
    
    // Function to handle location selection on the map
    private func selectLocation(_ location: Location) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
        selectedLocationID = location.locationID
    }
    
    // Overlay to show a list of items found at the selected location
    private func createListOverlay(locationID: Int) -> some View {
        let itemsAtLocation = lostItemsData.filter { $0.locationID == locationID }
        
        return AnyView(
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { selectedLocationID = nil }
                
                VStack {
                    Text("\(locations.first { $0.locationID == locationID }?.name ?? "")")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                    
                    List(itemsAtLocation) { item in
                        Button(action: {
                            selectedItem = item
                            showItemAlert = true
                        }) {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.itemDescription)
                                    .font(.subheadline)
                                Image(item.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(width: 350, height: 300)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .foregroundColor(.black)
                    
                    Button(action: { selectedLocationID = nil }) {
                        Text("Close")
                    }
                    .padding()
                }
                .alert(item: $selectedItem) { item in
                    Alert(
                        title: Text("Item Details"),
                        message: Text(item.itemDescription),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        )
    }
    
    // Header view with navigation buttons
    private var headerView: some View {
        HStack {
            Button(action: { navigateToDashboardView.toggle() }) {
                Label("My dashboard", systemImage: "person.crop.circle")
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { navigateToSettingView.toggle() }) {
                Label("Setting", systemImage: "gearshape.fill")
            }
            .foregroundColor(.white)
        }
        .padding()
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    // Action buttons for reporting items
    private var actionButtons: some View {
        VStack {
            Button("I found an item") {
                navigateToFoundView = true
            }
            .buttonStyle(ActionButtonStyle())
            
            Button("I lost an item") {
                navigateToLostView = true
            }
            .buttonStyle(ActionButtonStyle())
        }
        .padding()
    }
}

// Custom button style for action buttons
struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .foregroundColor(.black)
            .padding(.horizontal)
    }
}

// Preview provider for testing the UI
struct UserUIView_Previews: PreviewProvider {
    static var previews: some View {
        UserUIView(isLoggedIn: .constant(true))
    }
}
