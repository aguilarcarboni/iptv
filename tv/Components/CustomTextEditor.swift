import SwiftUI

struct CustomTextEditor<Value: InputConvertible>: View {
    @Binding var value: Value
    var isDisabled: Bool = false
    var label: String
    @State private var text: String
    
    init(value: Binding<Value>, label: String, isDisabled: Bool = false) {
        self._value = value
        self.label = label
        self.isDisabled = isDisabled
        self._text = State(initialValue: value.wrappedValue.description)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.subheadline)
                .padding(.bottom, 2)
                .foregroundColor(Color("Foreground"))

            TextEditor(text: $text)
                .onChange(of: text) { newValue in
                    if let newValue = Value(newValue) {
                        value = newValue
                    }
                }
                .disabled(isDisabled)
                .background(Color("Muted"))
                .padding(.vertical, 10)
                .cornerRadius(10)
        }
    }
}

struct CustomTextEditor_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var inputText: String = ""

        var body: some View {
            CustomTextEditor(
                value: $inputText,
                label: "Description"
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
