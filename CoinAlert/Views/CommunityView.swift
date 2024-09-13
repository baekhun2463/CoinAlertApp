import SwiftUI

struct CommunityView: View {
    @State private var errorMessage: String?
    @State var posts: [Post] = []
    @State private var selectedPost: Post? = nil // 선택된 포스트
    
    var body: some View {
        NavigationView {
            List {
                ForEach(posts.indices, id: \.self) { index in
                    let post = posts[index]
                    VStack(alignment: .leading) {
                        HStack {
                            if let avatarUrlString = post.avatar_url, let avatarUrl = URL(string: avatarUrlString) {
                                AsyncImage(url: avatarUrl) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .opacity(0.5)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle()) // 이미지에 원형 클립 적용
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            VStack(alignment: .leading) {
                                Text(post.author)
                                    .font(.subheadline)
                                Text(post.title)
                                    .font(.headline)
                                Text(post.timestamp)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "ellipsis")
                        }
                        Text(post.content)
                            .padding(.vertical, 5)
                        HStack {
                            // 댓글 버튼
                            Button(action: {
                                commentButtonTapped(for: index) // 댓글 버튼 눌림
                            }) {
                                HStack {
                                    Image(systemName: "bubble.right")
                                    Text("\(post.commentCount)")
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle()) // 개별 버튼 터치 영역 설정

                            Spacer()

                            // 좋아요 버튼
                            Button(action: {
                                toggleLike(for: index) // 좋아요 버튼 눌림
                            }) {
                                HStack {
                                    Image(systemName: post.isLiked ?? false ? "heart.fill" : "heart")
                                        .foregroundColor(post.isLiked ?? false ? .red : .gray)
                                    Text("\(post.likes)")
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle()) // 개별 버튼 터치 영역 설정
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Community", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: NewPostView()) {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
            })
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post)
            }
        }
        .onAppear(perform: fetchPosts)
    }
    
    func toggleLike(for index: Int) {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else { return }
        guard let url = URL(string: "\(baseURL)/posts/toggleLike") else { return }
        guard let token = getJWTFromKeychain() else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Prepare data to be sent
        var post = posts[index]
        let isLiked = !(post.isLiked ?? false)
        post.isLiked = isLiked
        
        let postData: [String: Any] = [
            "postId": post.id,
            "isLiked": isLiked
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: postData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to toggle like: \(error.localizedDescription)"
                }
                return
            }
            
            DispatchQueue.main.async {
                // Update the local state
                if isLiked {
                    self.posts[index].likes += 1
                } else {
                    self.posts[index].likes -= 1
                }
                self.posts[index].isLiked = isLiked
            }
        }.resume()
    }
    
    func commentButtonTapped(for index: Int) {
        // Comment 버튼이 눌렸을 때 동작
        selectedPost = posts[index] // 모달을 띄울 포스트를 설정
    }

    func fetchPosts() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else { return }
        guard let url = URL(string: "\(baseURL)/posts/getPosts") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        guard let token = getJWTFromKeychain() else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data returned"
                    print("Error: No data returned")
                }
                return
            }
            
            // 수신한 데이터를 JSON 문자열로 변환하여 로그 출력
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON string: \(jsonString)")
            }
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.async {
                    self.posts = posts
                    print("Decoded posts: \(posts)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode posts: \(error.localizedDescription)"
                    print("Decoding error: \(error.localizedDescription)")
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
            print("JWT 가져오기 실패: \(status)")
            return nil
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

