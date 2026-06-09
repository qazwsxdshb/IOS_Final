import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab { case home, profile }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("主選單", systemImage: "house.fill")
                }
                .tag(Tab.home)

            ProfileView()
                .tabItem {
                    Label("我的紀錄", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .tint(Color(red: 0.26, green: 0.52, blue: 0.96))
        .onAppear {
            // 把 TabBar 背景改成深色
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 0.02, green: 0.05, blue: 0.15, alpha: 1)
            
            // 未選中的圖示顏色
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.4)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.white.withAlphaComponent(0.4)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
