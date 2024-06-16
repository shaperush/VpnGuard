import SwiftUI
struct TutorialPage {
    var image: String
    var title: String
    var about: String
}

struct StartTutorialView: View {
    let tutorialPages: [TutorialPage] = [
        TutorialPage(image: "tuorLocationIco", title: "Super fast Connection", about: "Experience lightning-fast connections with our VPN, ensuring seamless streaming, browsing, and downloading without any lag or interruptions."),
        TutorialPage(image: "tutorСodingIco", title: "Secure Browsing", about: "Enjoy secure browsing with our VPN, protecting your data and privacy with top-notch encryption and advanced security features."),
        TutorialPage(image: "tutorProductlaunchIco", title: "Access Internet Around the World", about: "Unlock the internet around the world with our VPN, giving you access to global content and websites from anywhere with ease.")
    ]
    @AppStorage("isShowTutorial") var isShowTutorial = true
    @State var currentPage = 0
    @Binding var showPremiumView: Bool
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(tutorialPages.indices, id: \.self) { index in
                    TutorialPageView(page: tutorialPages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            if tutorialPages.count > 1 {
                Button(action: {
                    currentPage += 1
                    if currentPage >= tutorialPages.count {
                        withAnimation(Animation.easeIn(duration: 1.0)) {
                            showPremiumView.toggle()
                            isShowTutorial.toggle()
                        }
                    }
                }) {
                    Text(AppStrings.continueButton)
                        .textCase(.uppercase)
                        .frame(height: 48)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.white)
                        .background(.appAction)
                        .font(.system(size: 16, weight: .semibold))
                        .cornerRadius(10.0)
                        .padding(.horizontal, 20)
                }.buttonStyle(.plain)
            }
        }.background(.appBg)
    }
}

struct TutorialPageView: View {
    var page: TutorialPage
    
    var body: some View {
        VStack {
            Spacer()
            Image(page.image)
                .aspectRatio(contentMode: .fit)
            Spacer()
            Text(page.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .padding()
                .multilineTextAlignment(.center)
            Text(page.about)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.secondary)
                .padding()
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}


#Preview {
    StartTutorialView(showPremiumView: .constant(false))
}
