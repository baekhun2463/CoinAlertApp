import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var comments: [PostComment] = []
    @State private var newComment: String = ""
    @State private var nickName: String = "" // 닉네임을 서버에서 가져오기 때문에 초기값은 빈 문자열
    @State private var errorMessage: String? // 오류 메시지 상태 추가


    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.largeTitle)
                    .padding(.bottom, 5)

                Text(post.content)
                    .font(.body)
                    .padding(.bottom, 10)

                Divider()

                ScrollView {
                    ForEach(comments.indices, id: \.self) { index in
                        let comment = comments[index]
                        VStack(alignment: .leading) {
                            HStack {
                                Text(comment.author)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Button(action: {
                                    toggleCommentLike(for: index)
                                }) {
                                    HStack {
                                        Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                                            .foregroundColor(comment.isLiked ? .red : .gray)
                                        Text("\(comment.likes)") // 좋아요 수 표시
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            Text(comment.content)
                                .padding(.vertical, 5)
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .padding()

            HStack {
                TextField("댓글을 입력하세요...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    addComment()
                }) {
                    Text("게시")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationBarTitle("Post Details", displayMode: .inline)
        .onAppear {
            fetchComments()
            fetchCurrentUser()
        }
    }

    func fetchComments() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else { return }
        guard let url = URL(string: "\(baseURL)/comments/getComments/\(post.id)") else { return }
        guard let token = getJWTFromKeychain() else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch comments: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data returned from comments fetch")
                return
            }

            do {
                let fetchedComments = try JSONDecoder().decode([PostComment].self, from: data)
                DispatchQueue.main.async {
                    self.comments = fetchedComments
                }
            } catch {
                print("Failed to decode comments data: \(error.localizedDescription)")
            }
        }.resume()
    }


    func addComment() {
        guard !newComment.isEmpty else { return }
        let newCommentObj = PostComment(id: comments.count + 1, content: newComment, author: nickName, likes: 0, isLiked: false)
        comments.append(newCommentObj)
        newComment = ""
        // 추가: 백엔드에 댓글을 저장하는 API 호출
        saveCommentToBackend(comment: newCommentObj)
    }

    func toggleCommentLike(for index: Int) {
        comments[index].isLiked.toggle()
        if comments[index].isLiked {
            comments[index].likes += 1
        } else {
            comments[index].likes -= 1
        }
        // 추가: 백엔드에 좋아요 상태를 저장하는 API 호출
        updateCommentLikeInBackend(comment: comments[index])
    }

    func fetchCurrentUser() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            errorMessage = "서버 URL을 가져오는 데 실패했습니다."
            return
        }
        
        guard let token = getJWTFromKeychain() else {
            errorMessage = "인증 토큰을 가져오는 데 실패했습니다."
            return
        }
        
        guard let url = URL(string: "\(baseURL)/auth/getNickname") else {
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
                    errorMessage = "닉네임을 가져오는 데 실패했습니다."
                    return
                }

                if let data = data, let result = try? JSONDecoder().decode(NicknameResponse.self, from: data) {
                    nickName = result.nickname
                } else {
                    errorMessage = "데이터를 파싱하는 데 실패했습니다."
                }
            }
        }.resume()
    }

    func saveCommentToBackend(comment: PostComment) {
        // 백엔드에 댓글을 저장하는 로직
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else { return }
        guard let url = URL(string: "\(baseURL)/comments/newComment") else { return }
        guard let token = getJWTFromKeychain() else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let commentData: [String: Any] = [
            "postId": post.id,
            "content": comment.content,
            "author": comment.author
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: commentData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to save comment: \(error.localizedDescription)")
                return
            }
        }.resume()
    }

    func updateCommentLikeInBackend(comment: PostComment) {
        // 백엔드에 댓글의 좋아요 상태를 저장하는 로직
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else { return }
        guard let url = URL(string: "\(baseURL)/comments/toggleLike") else { return }
        guard let token = getJWTFromKeychain() else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let likeData: [String: Any] = [
            "commentId": comment.id,
            "isLiked": comment.isLiked
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: likeData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to update like status: \(error.localizedDescription)")
                return
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