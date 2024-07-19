//
//  SetAlertView.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//

import SwiftUI

struct SetAlertView: View {
    @State private var alertPrice: String = ""
    @State private var bitcoinPrice: Double?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @Environment(\.presentationMode) var presentationMode
    var onSave: (Double) -> Void
    
    var body: some View {
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
                    Text("$\(bitcoinPrice, specifier: "%.0f")")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    TextField("가격 입력", text: $alertPrice)
                        .keyboardType(.decimalPad)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        if let price = Double(alertPrice) {
                            onSave(price)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("확인")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func fetchBitcoinPrice() {
        BitcoinPriceService().fetchBitcoinPrice { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let price):
                    bitcoinPrice = price.price
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct SetAlertView_Previews: PreviewProvider {
    static var previews: some View {
        SetAlertView(onSave: { _ in })
    }
}
