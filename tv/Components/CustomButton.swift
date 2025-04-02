import SwiftUI

// TODO: add confetti option onSubmit
// TODO: make fontWeight an optional parameter (default to .medium)
struct CustomButton: View {
    let action: () -> Void
    let label: String

    var backgroundColor: Color?
    var foregroundColor: Color?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            Text(label).fontWeight(.medium)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(Color("AccentColor"))
        .foregroundColor(Color.white)
        .buttonStyle(PlainButtonStyle())
        .cornerRadius(8)
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(action: {
            print("Button tapped!")
        }, label: "Button")
    }
}
