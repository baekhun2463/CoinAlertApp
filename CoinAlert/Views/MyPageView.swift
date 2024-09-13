import SwiftUI
import PhotosUI

struct MyPageView: View {
    @State private var nickName: String = "" // 닉네임을 서버에서 가져오기 때문에 초기값은 빈 문자열
    @State private var email: String = ""
    @State private var avatarUrl: String = ""
    @State private var profileImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var errorMessage: String? // 오류 메시지 상태 추가
    @AppStorage("authToken") var authToken: String?
    
    @State private var userPosts: [Post] = [] // 사용자가 작성한 게시글
    @State private var userComments: [PostComment] = [] // 사용자가 남긴 댓글

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 20) {
                    Text("내 정보 수정")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    // 닉네임을 사용하여 인사 메시지 표시
                    Text("안녕하세요, \(nickName)님")
                        .font(.title2)
                        .padding(.bottom, 10)
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        CustomImagePicker(image: $profileImage)
                    }
                }
                .padding()
                .background(Color.white) // 배경색을 설정하여 고정된 상단 부분과 스크롤 내용 부분을 구분
                
                Spacer()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 사용자 게시글 목록
                        Text("내가 작성한 게시글")
                            .font(.headline)
                            .padding(.top)

                        ForEach(userPosts) { post in
                            VStack(alignment: .leading) {
                                Text(post.title)
                                    .font(.headline)
                                Text(post.content)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(post.timestamp)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Divider()
                            }
                            .padding(.horizontal)
                        }

                        // 사용자 댓글 목록
                        Text("내가 남긴 댓글")
                            .font(.headline)
                            .padding(.top)

                        ForEach(userComments) { comment in
                            VStack(alignment: .leading) {
                                Text(comment.content)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Likes: \(comment.likes)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Divider()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                fetchUserData() // 뷰가 나타날 때 사용자 데이터를 가져오기
            }
        }
    }
    
    private func fetchUserData() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            errorMessage = "서버 URL을 가져오는 데 실패했습니다."
            return
        }
        
        guard let token = getJWTFromKeychain() else {
            errorMessage = "인증 토큰을 가져오는 데 실패했습니다."
            return
        }
        
        guard let url = URL(string: "\(baseURL)/auth/getMemberData") else {
            errorMessage = "잘못된 URL입니다."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "오류 발생: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "사용자 데이터를 가져오는 데 실패했습니다."
                    return
                }

                if let data = data, let result = try? JSONDecoder().decode(UserDataResponse.self, from: data) {
                    nickName = result.nickname
                    
                    // avatar_url이 nil이 아닌 경우에만 값을 설정
                    if let avatar = result.avatar_url {
                        avatarUrl = avatar
                    } else {
                        avatarUrl = "기본 이미지 URL" // 기본 이미지를 설정하거나 빈 문자열로 설정
                    }
                    
                    userPosts = result.posts
                    userComments = result.comments
                } else {
                    errorMessage = "데이터를 파싱하는 데 실패했습니다."
                }
            }
        }.resume()
    }

    private func getJWTFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            errorMessage = "JWT 가져오기 실패: \(status)"
            return nil
        }
    }
}

struct UserDataResponse: Decodable {
    let nickname: String
    let avatar_url: String?
    let posts: [Post]
    let comments: [PostComment]

}


struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.image = uiImage
            } else if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    MyPageView()
}
