import Foundation
import SwiftUI

@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var pdfURL: URL?
    @Published var showingPDFPreview = false
    
    func fetchEvents() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let fetchedEvents = try await EventService.shared.fetchEvents()
                await MainActor.run {
                    self.events = fetchedEvents
                    self.isLoading = false
                    print("Updated events array with \(fetchedEvents.count) events")
                    
                    // Debug: Print all events
                    for event in self.events {
                        print("Loaded event: \(event.title), ID: \(event.id)")
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = "Failed to load events: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Error fetching events: \(error)")
                }
            }
        }
    }
    
    func participateInEvent(_ eventId: String) {
        Task {
            do {
                let updatedEvent = try await EventService.shared.participateInEvent(eventId: eventId)
                if let index = self.events.firstIndex(where: { $0.id == eventId }) {
                    self.events[index] = updatedEvent
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func downloadVoucher(for eventId: String) {
        Task {
            do {
                let fileURL = try await EventService.shared.downloadVoucher(eventId: eventId)
                self.pdfURL = fileURL
                self.showingPDFPreview = true
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
