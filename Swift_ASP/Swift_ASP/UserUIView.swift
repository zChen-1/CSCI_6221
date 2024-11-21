import SwiftUI
import MapKit
import Supabase

struct Location: Identifiable {
    var id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var locationID: Int
}

struct ItemSupaHome: Codable, Identifiable {
    let id : Int
    let item_name: String
    let category: String
    let reported_by: UUID?
    let is_active: Bool
    let item_description: String
    let location: String
    let item_image: String?
}

struct ItemDetailModal: View {
    let item: ItemSupaHome
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        if let imageUrl = item.item_image {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                        }
                        
                        Group {
                            DetailRow(title: "Item Name", value: item.item_name)
                            DetailRow(title: "Category", value: item.category)
                            DetailRow(title: "Description", value: item.item_description)
                            DetailRow(title: "Location", value: item.location)
                            DetailRow(title: "Status", value: item.is_active ? "Active" : "Inactive")
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .padding()
                
                Button("Close") {
                    isPresented = false
                }
                .padding()
                .frame(width: 200)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: 600)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
        }
    }
}

struct UserUIView: View {
    @State private var navigateToLostView = false
    @State private var navigateToFoundView = false
    @State private var navigateToUserView: Bool = false
    @Binding var navigateToChatView: Bool
    @Binding var isLoggedIn: Bool
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.899902, longitude: -77.047201),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    )
    
    @State private var selectedLocation: Location? = nil
    @State private var selectedItem: ItemSupaHome? = nil
    @State private var showDetailModal = false
    @State private var items: [ItemSupaHome] = []
    
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://trzpyocnxmimgvauphjm.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyenB5b2NueG1pbWd2YXVwaGptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE3ODgwNzcsImV4cCI6MjA0NzM2NDA3N30.LHu4FCxWJFgx-iDJXEjoGmtIi7PtfJcZA2GkJ1gy1JQ"
    )
    
    let locations = [
        Location(name: "The George Washington University Hospital", coordinate: CLLocationCoordinate2D(latitude: 38.901253, longitude: -77.050670), locationID: 1),
        Location(name: "The School of Engineering and Applied Science (SEAS)", coordinate: CLLocationCoordinate2D(latitude: 38.899934, longitude: -77.049120), locationID: 2),
        Location(name: "The Columbian College of Arts and Sciences (CCAS)", coordinate: CLLocationCoordinate2D(latitude: 38.900169, longitude: -77.047080), locationID: 3)
    ]
    
    func fetchItems() async {
        do {
            let response: [ItemSupaHome] = try await supabase
                .from("items")
                .select()
                .execute()
                .value
            
            DispatchQueue.main.async {
                self.items = response
            }
        } catch {
            print("Error fetching items: \(error)")
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
                
                if let location = selectedLocation {
                    createListOverlay(location: location)
                }
                
                if showDetailModal, let item = selectedItem {
                    ItemDetailModal(item: item, isPresented: $showDetailModal)
                }
                
                actionButtons
                
                Spacer()
            }
            .task {
                await fetchItems()
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
            
            NavigationLink(destination: ViewFoundItems(navigateToUserView: $navigateToUserView), isActive: $navigateToFoundView) { EmptyView() }
            NavigationLink(destination: ViewLostItems(navigateToUserView: $navigateToUserView), isActive: $navigateToLostView) { EmptyView() }
            NavigationLink(destination: ChatListView(), isActive: $navigateToChatView) { EmptyView() }
            
            Spacer()
            bottomToolbar
        }
    }
    
    private func selectLocation(_ location: Location) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
        selectedLocation = location
    }
    
    private func createListOverlay(location: Location) -> some View {
        // Filter items by matching location name
        let itemsAtLocation = items.filter { $0.location == location.name }
        
        return AnyView(
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { selectedLocation = nil }
                
                VStack {
                    Text(location.name)
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                    
                    if itemsAtLocation.isEmpty {
                        Text("No items reported at this location")
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        List(itemsAtLocation) { item in
                            Button(action: {
                                selectedItem = item
                                showDetailModal = true
                            }) {
                                VStack(alignment: .leading) {
                                    Text(item.item_name)
                                        .font(.headline)
                                    Text(item.category)
                                        .font(.subheadline)
                                    Text(item.location)
                                        .font(.subheadline)
                                    Text(item.item_description)
                                        .font(.subheadline)
                                    if let imageUrl = item.item_image {
                                        AsyncImage(url: URL(string: imageUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 100)
                                            case .failure(_):
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 100)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .frame(width: 350, height: 300)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .foregroundColor(.black)
                    }
                    
                    Button(action: { selectedLocation = nil }) {
                        Text("Close")
                    }
                    .padding()
                }
            }
        )
    }
    
    // Bottom toolbar
    private var bottomToolbar: some View {
            HStack {
                // Chat button
                Button(action: {
                           navigateToChatView = true  // This triggers the navigation
                       }) {
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
        UserUIView( navigateToChatView: .constant(false),isLoggedIn: .constant(true))
            
    }
}
