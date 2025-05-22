import SwiftUI

struct RootView: View {
    @State private var hasEnteredName = false
    @State private var userName = ""

    var body: some View {
        if hasEnteredName {
            ContentView(userName: userName)
        } else {
            WelcomeView(userName: $userName, hasEnteredName: $hasEnteredName)
        }
    }
}
