import SwiftUI

struct CommunityView: View {
    @State private var errorMessage: String?
    @State var posts: [Post] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(posts.indices, id: \.self) { index in
                    let post = posts[index]
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text(post.title)
                                    .font(.headline)
                                Text(post.timestamp) // 그대로 문자열로 사용
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "ellipsis")
                        }
                        Text(post.content)
                            .padding(.vertical, 5)
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "bubble.right")
                                Text("\(post.commentCount)")
                            }
                            Spacer()
                            Button(action: {
                                toggleLike(for: index)
                            }) {
                                Image(systemName: post.isLiked ?? false ? "heart.fill" : "heart")
                                    .foregroundColor(post.isLiked ?? false ? .red : .gray)
                                Text("\(post.likes)")
                            }
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
        }
        .onAppear(perform: fetchPosts) // 뷰가 나타날 때 게시글을 가져옵니다.
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
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data returned"
                }
                return
            }
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.async {
                    self.posts = posts
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode posts: \(error.localizedDescription)"
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
