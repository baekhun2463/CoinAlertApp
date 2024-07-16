//
//  MainView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("Welcome to Main View")
                .font(.largeTitle)
                .padding()
            // 메인 화면의 내용 추가
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    MainView()
}
