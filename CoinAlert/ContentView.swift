//
//  ContentView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI

struct MainView: View{
    var body: some View {
        VStack{
            Text("메인 화면임")
                .font(.largeTitle)
                .padding()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct SplashView: View {
    var body: some View {
        VStack {
            Spacer()
            
            //로고 들어갈 자리
            Text("이미지 들어갈 자리")
                .font(.largeTitle)
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView: View {
    
    @State private var showMainView = false
    
    func loadData() {
        DispatchQueue.global().async {
            sleep(1)
            
            DispatchQueue.main.async {
                showMainView = true
            }
        }
    }
    
    var body: some View {
        Group {
            if showMainView {
                MainView()
            } else {
                SplashView()
                    .onAppear {
                        loadData()
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


