import SwiftUI
import SwiftData

@main
struct FunnyTimeApp: App {
    let container: ModelContainer
    @State private var showingIconGenerator = false
    
    init() {
        do {
            let schema = Schema([TimeRecord.self, WeeklyWorkdays.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingIconGenerator = true }) {
                            Image(systemName: "app.badge.fill")
                        }
                    }
                }
                .sheet(isPresented: $showingIconGenerator) {
                    IconGeneratorView()
                }
        }
        .modelContainer(container)
    }
}
