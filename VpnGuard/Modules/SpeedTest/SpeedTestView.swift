import SwiftUI

struct SpeedTestView: View {
    @EnvironmentObject var paywallService: PaywallService
    @StateObject var viewModel: SpeedTestViewModel = SpeedTestViewModel()
    @Binding var showSideMenu: Bool
    @Binding var showPremiumView: Bool
    var body: some View {
        VStack {
            HeaderToolbarView(showSideMenu: $showSideMenu, showPremiumView: $showPremiumView)
                .environmentObject(paywallService)
            ConnectedInfoView(download: $viewModel.downloadSpeed, upload: $viewModel.uploadSpeed)
            
            Spacer()
            SpeedProgressView(viewModel: viewModel)
            Text(viewModel.status == .download ? viewModel.downloadSpeed : viewModel.uploadSpeed)
                .frame(height: 20)
                .padding()
                .font(.system(size: 24, weight: .semibold))
            Spacer()
        }.background(.appBg)
        .hiddenTabBar()
        .onAppear {
            viewModel.downloadSpeed = "__.__"
            viewModel.uploadSpeed = "__.__"
        }
    }
}

struct SpeedProgressView: View {
    @ObservedObject var viewModel: SpeedTestViewModel
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.shadowButton, lineWidth: 24)
                .frame(width: 250, height: 250)
            Circle()
                .fill(.appAction)
                .frame(width: 180, height: 180)
            
            Button {
                if viewModel.status.isEnabled {
                    viewModel.startTest()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.appAction)
                        .frame(width: 180, height: 180)
                    Text(viewModel.status.title)
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .bold))
                }
            }.frame(width:200, height: 200)
                
            ForEach(Array(stride(from: 0, through: 10, by: 1)), id: \.self) { i in
                Text("\(i * 10)")
                    .rotationEffect(.degrees(-120 - Double(i * 30)))
                    .offset(x: 160)
                    .rotationEffect(.degrees(Double(i * 30)))
            }
            .rotationEffect(.degrees(120))
            
            Circle()
                .trim(from: 0.1, to: viewModel.progress)
                .stroke(.appAction, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(90))
                .animation(.default, value: viewModel.progress)
        }
    }
}

#Preview {
    SpeedTestView(viewModel: SpeedTestViewModel(), showSideMenu: .constant(false), showPremiumView: .constant(false))
}
