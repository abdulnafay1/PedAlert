import SwiftUI

struct WelcomeView: View {
    @Binding var userName: String
    @Binding var hasEnteredName: Bool

    var body: some View {
        ZStack {
            Image("welcome_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("ped_logo")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding()

                Text("Welcome to PedAlert")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)

                Text("Please enter your name to continue:")
                    .foregroundColor(.white)

                TextField("Your Name", text: $userName)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .padding(.horizontal, 40)

                Button("Continue") {
                    if !userName.isEmpty {
                        hasEnteredName = true
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}
