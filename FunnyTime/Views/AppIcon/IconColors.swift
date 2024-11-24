import SwiftUI

struct IconColors {
    static let lightBackground = [
        Color(red: 255/255, green: 182/255, blue: 193/255),
        Color(red: 255/255, green: 218/255, blue: 185/255)
    ]
    
    static let darkBackground = [
        Color(red: 70/255, green: 90/255, blue: 120/255),
        Color(red: 45/255, green: 55/255, blue: 95/255)
    ]
    
    static let lightMouth = [
        Color(red: 255/255, green: 99/255, blue: 71/255),
        Color(red: 255/255, green: 127/255, blue: 80/255)
    ]
    
    static let darkMouth = [
        Color(red: 100/255, green: 149/255, blue: 237/255),
        Color(red: 70/255, green: 130/255, blue: 180/255)
    ]
    
    static let lightCheeks = Color(red: 255/255, green: 182/255, blue: 193/255).opacity(0.3)
    static let darkCheeks = Color.white.opacity(0.1)
} 