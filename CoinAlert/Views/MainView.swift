//
//  MainView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/16/24.
//

import SwiftUI

struct MainView: View {
    @State private var bitcoinPrice: PriceData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .onAppear {
                            fetchBitcoinPrice()
                        }
                } else if let bitcoinPrice = bitcoinPrice {
                    VStack {
                        Text("Bitcoin Price")
                            .font(.largeTitle)
                        Text("$\(bitcoinPrice.price, specifier: "%.0f")")
                            .font(.title)
                            .foregroundColor(.green)
                        //차트 표시하는 자리
                    }
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Bitcoin Tracker")
        }
    }
    
    func fetchBitcoinPrice() {
        BitcoinPriceService().fetchBitcoinPrice { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let price):
                    bitcoinPrice = price
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
