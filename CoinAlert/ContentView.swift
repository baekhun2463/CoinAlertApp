//
//  ContentView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI


struct ContentView: View {
    
    @AppStorage("authToken") var authToken: String?

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
                if let token = authToken, !token.isEmpty {
                    MainTabView()
                }else {
                    LoginView()
                }
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


