//
//  EditProfileView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/21/24.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @State private var nickName: String = ""
    @State private var email: String = ""
    @State private var profileImage: UIImage?
    @State private var showImagePicker: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("내 정보 수정")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            
            TextField("닉네임", text: $nickName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Button(action: {
                // 저장 액션
            }) {
                Text("저장")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}


struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
