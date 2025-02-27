import SwiftUI

struct TVGuideView: View {
    @State private var selectedDate = Date()
    let timeSlots = ["6:00 AM", "8:00 AM", "10:00 AM", "12:00 PM", 
                     "2:00 PM", "4:00 PM", "6:00 PM", "8:00 PM", "10:00 PM"]
    
    let channels = [
        "Channel 1", "Channel 2", "Channel 3", "Channel 4", 
        "Channel 5", "Channel 6", "Channel 7", "Channel 8"
    ]
    
    var body: some View {
        
        // Guide grid
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                // Time header
                HStack(alignment: .top, spacing: 0) {
                    // Channel column
                    Text("Channels")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, height: 40)
                        .background(Color.gray.opacity(0.1))
                        .padding(.trailing, 1)
                    
                    // Time slots
                    ForEach(timeSlots, id: \.self) { time in
                        Text(time)
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 150, height: 40)
                            .background(Color.gray.opacity(0.1))
                            .padding(.trailing, 1)
                    }
                }
                
                // Channel rows
                ForEach(channels, id: \.self) { channel in
                    HStack(alignment: .top, spacing: 0) {
                        // Channel name
                        VStack {
                            Text(channel)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 120, height: 70)
                        .background(Color.gray.opacity(0.05))
                        .padding(.trailing, 1)
                        
                        // Programs
                        ForEach(timeSlots.indices, id: \.self) { index in
                            let randomWidth = [1, 1, 1, 2, 2, 3].randomElement()! * 150
                            if index % randomWidth == 0 || index == 0 {
                                programCell(channel: channel, index: index)
                                    .frame(width: CGFloat(randomWidth), height: 70)
                                    .padding(.trailing, 1)
                            }
                        }
                    }
                    .padding(.top, 1)
                }
            }
        }
    }
    
    @ViewBuilder
    func programCell(channel: String, index: Int) -> some View {
        let programs = [
            "Morning Show", "News", "Movie", "Documentary", 
            "Sports", "Kids Show", "Reality TV", "Talk Show"
        ]
        let randomProgram = programs.randomElement()!
        
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(programColor(for: randomProgram))
            
            VStack(alignment: .leading) {
                Text(randomProgram)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(timeSlots[index]) - \(timeSlots[min(index + 1, timeSlots.count - 1)])")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.leading, 8)
        }
    }
    
    func programColor(for type: String) -> Color {
        switch type {
        case "Morning Show": return Color.blue
        case "News": return Color.red
        case "Movie": return Color.purple
        case "Documentary": return Color.green
        case "Sports": return Color.orange
        case "Kids Show": return Color.pink
        case "Reality TV": return Color.teal
        case "Talk Show": return Color.indigo
        default: return Color.gray
        }
    }
    
    func dayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}