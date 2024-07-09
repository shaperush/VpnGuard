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
        TutorialPage(image: "tutorProductlaunchIco", title: "Access Internet Around the World", about: "Unlock the internet around the world with our VPN, giving you access to global content and websites from anywhere with ease."),
        TutorialPage(image: "", title: "", about: "")
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
                    Text( currentPage == 3 ? AppStrings.continueTermsButton : AppStrings.continueButton)
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
    @Environment(\.openURL) var openURL
    var body: some View {
        VStack {
            if page.title.isEmpty {
                Spacer()
                Image(.appstoreIco)
                    .resizable()
                    .frame(width: 150, height: 150)
                    .cornerRadius(10.0)
                Spacer()
                Text(AppStrings.termsLastScreen)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.appTitle)
                
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
                HStack(spacing: 0) {
                    Button {
                        openURL(URL(string: AppConstants.TUTORIAL_TERMS_URL)!)
                    } label: {
                        Text("Terms of Use")
                            .frame(height: 48)
                            .frame( alignment: .leading)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.appAction)
                            .padding(.horizontal)
                    }.buttonStyle(.plain)
                    
                    
                    Button {
                        openURL(URL(string: AppConstants.TUTORIAL_POLICY_URL)!)
                    } label: {
                        Text("Privacy Policy")
                            .frame(height: 48)
                            .frame(alignment: .trailing)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.appAction)
                            .padding(.horizontal)
                    }.buttonStyle(.plain)
                }
                Spacer()
            } else {
                Spacer()
                Image(page.image)
                    .aspectRatio(contentMode: .fit)
                Spacer()
                Text(page.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.appTitle)
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
}


#Preview {
    StartTutorialView(showPremiumView: .constant(false))
}
