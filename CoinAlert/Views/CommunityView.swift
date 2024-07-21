//
//  CommunityView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI
import SwiftData

struct CommunityView: View {

    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    @Query var posts: [Post]

    
    var body: some View {
        NavigationView {
            List {
                ForEach(posts) { post in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text("\(post.title)")
                                    .font(.headline)
                                Text("\(post.timestamp, formatter: itemFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "ellipsis")
                        }
                        Text("\(post.content)")
                            .padding(.vertical, 5)
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "bubble.right")
                                Text("\(post.comments)")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "heart")
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
    }
}



struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

