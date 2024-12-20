import SwiftUI
import QuickLook

struct EventsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel = EventsViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#fef2e4")
                .edgesIgnoringSafeArea(.all)
        
            NavigationView {
                ZStack {
                    Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#fef2e4")
                        .edgesIgnoringSafeArea(.all)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.events) { event in
                                    EventCard(event: event, viewModel: viewModel)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Events")
                .onAppear {
                    viewModel.fetchEvents()
                }
                .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                    Button("OK") {
                        viewModel.error = nil
                    }
                } message: {
                    Text(viewModel.error ?? "")
                }
                .sheet(isPresented: $viewModel.showingPDFPreview) {
                    if let pdfURL = viewModel.pdfURL {
                        QuickLookPreview(url: pdfURL)
                    }
                }
            }
        }
        .preferredColorScheme(themeManager.currentTheme)
    }
}


struct EventCard: View {
    let event: Event
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject var viewModel: EventsViewModel
    @State private var imageLoadError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                if let imageUrl = URL(string: event.imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .tint(Color(hex: themeManager.currentTheme == .dark ? "#fdfee4" : "#fdfee4"))
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 30))
                                        Text("Failed to load image")
                                            .font(.caption)
                                    }
                                    .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#4f3422" : "#4f3422"))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text("Invalid image URL")
                                .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#4f3422" : "#4f3422"))
                        )
                }
            }
            .frame(height: 150)  // Adjusted height to make the card smaller
            .clipped()
            .cornerRadius(12)
            
            Text(event.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)
            
            Text(event.description)
                .font(.body)
                .foregroundColor(.gray)
            
            HStack {
                Label(event.formattedDate(), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)
            }
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)
                Text(event.location)
                    .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)
            }
            
            HStack {
                Image(systemName: "person.3")
                    .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)
                Text("\(event.participants.count)/\(event.capacity) participants")
                    .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.participateInEvent(event.id)
                }) {
                    Text("Participate")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: themeManager.currentTheme == .dark ? "#4f3422" : "#4f3422"))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.downloadVoucher(for: event.id)
                }) {
                    Text("Get Voucher")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: themeManager.currentTheme == .dark ? "#4f3422" : "#4f3422"))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#fef2e4"))
        .cornerRadius(15)
        .shadow(radius: 5)
        .onAppear {
            print("Loading image for event: \(event.title)")
            print("Image URL: \(event.imageUrl)")
        }
    }
}



struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(url: url)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        
        init(url: URL) {
            self.url = url
            super.init()
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return url as QLPreviewItem
        }
    }
}

#Preview {
    EventsView()
}
