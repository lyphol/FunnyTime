import SwiftUI

struct TimePickerSheet: View {
    let title: String
    @Binding var time: Date
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DatePicker(
                    "",
                    selection: $time,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                    Button("确定") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onSave()
                            isPresented = false
                        }
                    }
                )
                .padding(.horizontal)
            }
            .background(Color(.systemBackground))
        }
        .presentationDetents([.height(240)])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
        .transition(.opacity)
    }
} 
