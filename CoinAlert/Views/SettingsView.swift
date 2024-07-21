import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("설정").font(.title).bold()) {
                    NavigationLink(destination: EditProfileView()) {
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.blue)
                            Text("내 정보 수정")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink(destination: ResetPasswordView()) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.blue)
                            Text("비밀번호 변경")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                            Text("알림 설정")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink(destination: DeleteAccountView()) {
                        HStack {
                            Image(systemName: "arrow.backward.square")
                                .foregroundColor(.blue)
                            Text("계정 탈퇴")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink(destination: LogoutView()) {
                        HStack {
                            Image(systemName: "arrow.turn.up.left")
                                .foregroundColor(.blue)
                            Text("로그아웃")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("설정", displayMode: .inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
