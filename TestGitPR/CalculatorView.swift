//
//  CalculatorView.swift
//  TestGitPR
//
//  Created by JLSANCHEZP on 3/10/24.
//

import SwiftUI

struct CalculatorView: View {
    @State private var display = "0"
    @State private var currentNumber = ""
    @State private var previousNumber = ""
    @State private var currentOperation: Operation? = nil

    enum Operation {
        case add, subtract, multiply, divide
    }

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text(display)
                .font(.largeTitle)
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(Color.black)
                .foregroundColor(.white)

            ForEach(buttonRows, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { button in
                        CalculatorButton(title: button, action: { self.buttonTapped(button) })
                    }
                }
            }
        }
        .padding()
    }

    var buttonRows: [[String]] {
        [
            ["7", "8", "9", "÷"],
            ["4", "5", "6", "×"],
            ["1", "2", "3", "-"],
            ["0", ".", "=", "+"]
        ]
    }

    func buttonTapped(_ button: String) {
        switch button {
        case "0"..."9", ".":
            currentNumber += button
            display = currentNumber

        case "+", "-", "×", "÷":
            if let number = Double(currentNumber) {
                previousNumber = currentNumber
                currentNumber = ""
                switch button {
                case "+": currentOperation = .add
                case "-": currentOperation = .subtract
                case "×": currentOperation = .multiply
                case "÷": currentOperation = .divide
                default: break
                }
            }

        case "=":
            if let operation = currentOperation, let previousValue = Double(previousNumber), let currentValue = Double(currentNumber) {
                var result: Double = 0
                switch operation {
                case .add: result = previousValue + currentValue
                case .subtract: result = previousValue - currentValue
                case .multiply: result = previousValue * currentValue
                case .divide: result = previousValue / currentValue
                }
                display = String(result)
                currentNumber = String(result)
                currentOperation = nil
            }

        default:
            break
        }
    }
}


#Preview {
    CalculatorView()
}
