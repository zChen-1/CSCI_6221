//
//  UserUIView.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/9.
//

import SwiftUI
import MapKit
import CloudKit

struct Location: Identifiable {
    var id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var locationID: Int
}

struct LostItems: Identifiable {
    var id = UUID()
    var name: String
    var itemType: String
    var itemDescription: String
    var locationID: Int
    var imageName: String
}

struct UserUIView: View {
    @State private var navigateToLostView = false
    @State private var navigateToSettingView = false
    @State private var navigateToDashboardView = false
    @State private var navigateToFoundView = false
    @State private var navigateToUserView: Bool = false
    @State private var navigateToChatView = false
    @Binding var isLoggedIn: Bool
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.899902, longitude: -77.047201),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    )
    //let lostItemsDatabase = CKContainer.default().publicCloudDatabase // Using CloudKit to save data of lost items
    @State private var selectedLocationID: Int? = nil
    @State private var selectedItem: LostItems? = nil
    @State private var showItemAlert = false
    
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
        LostItems(name: "Pen", itemType: "Office Supplies", itemDescription: "A black pen found at GW Hospital", locationID: 2, imageName: "No_Image_Available"),
        LostItems(name: "Pencil", itemType: "Office Supplies", itemDescription: "A black pencil found at SEAS", locationID: 3, imageName: "No_Image_Available"),
        LostItems(name: "Notebook", itemType: "Office Supplies", itemDescription: "A black notebook found at SEAS", locationID: 3, imageName: "No_Image_Available")
    ]
    
    
    func saveLostItemsToCloudKit(LostItems: [LostItems]) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase

        for item in LostItems {
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

    func fetchLostItemsFromCloudKit() {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let query = CKQuery(recordType: "LostItem", predicate: NSPredicate(value: true))

        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching records: \(error)")
                return
            }

            if let records = records {
                for record in records {
                    guard let name = record["name"] as? String,
                          let itemType = record["itemType"] as? String,
                          let itemDescription = record["itemDescription"] as? String,
                          let locationID = record["locationID"] as? Int,
                          let imageName = record["imageName"] as? String else { continue }

                    let lostItem = LostItems(name: name, itemType: itemType, itemDescription: itemDescription, locationID: locationID, imageName: imageName)
                    print("Fetched Lost Item: \(lostItem)")
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            HStack(alignment: .center) {
                Spacer()
            }
            
            VStack {
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
            
            // Navigation links
            NavigationLink(destination: ViewFoundItems(navigateToUserView: $navigateToUserView), isActive: $navigateToFoundView) { EmptyView() }
            NavigationLink(destination: ViewLostItems(), isActive: $navigateToLostView) { EmptyView() }
            NavigationLink(destination: SettingView(), isActive: $navigateToSettingView) { EmptyView() }
            Spacer()
            bottomToolbar
        }
    }
    
    private func selectLocation(_ location: Location) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
        selectedLocationID = location.locationID // Set selected location ID
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

struct UserUIView_Previews: PreviewProvider {
    static var previews: some View {
        UserUIView(isLoggedIn: .constant(true))
    }
}
