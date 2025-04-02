import SwiftUI

struct CustomDatePicker: View {
    @Binding var date: Date
    var label: String
    var components: DatePickerComponents = [.date, .hourAndMinute]
    
    init(date: Binding<Date>, label: String, components: DatePickerComponents = [.date, .hourAndMinute]) {
        self._date = date
        self.label = label
        self.components = components
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.subheadline)
                .padding(.bottom, 2)
                .foregroundColor(Color("Foreground"))
            
            DatePicker(
                "",
                selection: $date,
                displayedComponents: components
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .padding(.vertical, 8)
            .cornerRadius(7)
        }
    }
}

#Preview {
    @Previewable @State var date = Date()
    return CustomDatePicker(date: $date, label: "Follow-up Date")
} 
