import SwiftUI

struct CustomCard: View {
    var title: String?
    var description: String?
    var content: String?
    var footer: String?

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                VStack {
                    if let title = title {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("Foreground"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let description = description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(Color("Subtitle"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if let content = content {
                    Text(content)
                        .font(.callout)
                        .foregroundStyle(Color("Foreground"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let footer = footer {
                    Text(footer)
                        .font(.caption)
                        .foregroundStyle(Color("Subtitle"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
        }
        .background(Color("Background"))
            .background(RoundedRectangle(cornerRadius: 15))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 2)
    }
}

struct CustomCard_Previews: PreviewProvider {
    static var previews: some View {
        CustomCard(
            title: "Card title",
            description: "Card description",
            content: "Card content",
            footer: "Card footer"
        )
    }
}
