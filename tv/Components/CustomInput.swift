import SwiftUI

struct CustomInput<Value: InputConvertible>: View {
    @Binding var value: Value
    var label: String
    var isDisabled: Bool = false

    @State private var text: String
    
    init(value: Binding<Value>, label: String, iconName: String? = nil, isDisabled: Bool = false) {
        self._value = value
        self.label = label
        self.isDisabled = isDisabled
        self._text = State(initialValue: value.wrappedValue.description)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
                .fontWeight(Font.Weight.medium)
                .padding(.bottom, 2)
                .foregroundColor(Color("Foreground"))

            TextField("", text: $text)
                .accessibilityLabel(label)
                .onChange(of: text) { newValue in
                    if let newValue = Value(newValue) {
                        value = newValue
                    }
                }
                .disabled(isDisabled)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(Color("Foreground"))
                .background(Color("Muted"))
                .cornerRadius(7)
                .textFieldStyle(PlainTextFieldStyle())
        }
    }
}

struct CustomInput_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var inputText: String = ""

        var body: some View {
            CustomInput(
                value: $inputText,
                label: "Email"
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
