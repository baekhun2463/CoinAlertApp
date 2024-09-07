import SwiftUI

struct MainTabView: View {
    

    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("", systemImage: "house.fill")
                }
            
            CommunityView()
                .tabItem {
                    Label("", systemImage:"list.bullet.clipboard.fill")
                }
            
            AlertView()
                .tabItem {
                    Label("", systemImage: "light.beacon.max")
                }
            
            MyPageView()
                .tabItem {
                    Label("",systemImage: "person.fill")
                }
//            SettingsView()
//                .tabItem {
//                    Label("설정", systemImage: "gearshape.fill")
//                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
