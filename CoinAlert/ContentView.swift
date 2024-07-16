//
//  ContentView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI


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
                MainTabView()
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


