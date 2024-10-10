//
//  CalculatorButton.swift
//  TestGitPR
//
//  Created by JLSANCHEZP on 3/10/24.
//

import SwiftUI

struct CalculatorButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.largeTitle)
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(40)
        }
    }
}

#Preview {
    CalculatorButton(title: "+") {
        
    }
}
