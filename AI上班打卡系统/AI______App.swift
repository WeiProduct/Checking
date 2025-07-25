






import SwiftUI
import SwiftData
import AVFoundation

@main
struct AI______App: App {
    @StateObject private var userService = UserService()
    @StateObject private var languageService = LanguageService.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AttendanceRecord.self,
            UserSettings.self,
        ])
        
        // Clear the existing store to avoid migration issues during development
        let storeURL = URL.documentsDirectory.appending(path: "default.store")
        let fileManager = FileManager.default
        
        // Remove existing store files
        do {
            if fileManager.fileExists(atPath: storeURL.path) {
                try fileManager.removeItem(at: storeURL)
            }
            let shmURL = storeURL.appendingPathExtension("sqlite-shm")
            if fileManager.fileExists(atPath: shmURL.path) {
                try fileManager.removeItem(at: shmURL)
            }
            let walURL = storeURL.appendingPathExtension("sqlite-wal")
            if fileManager.fileExists(atPath: walURL.path) {
                try fileManager.removeItem(at: walURL)
            }
        } catch {
            print("Failed to remove existing store: \(error)")
        }
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LanguageSelectionView()
                .environmentObject(userService)
                .environmentObject(languageService)
        }
        .modelContainer(sharedModelContainer)
    }
}
