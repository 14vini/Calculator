//
//  ContentView.swift
//  Calculator
//
//  Created by Vinicius on 4/17/25.
//

import SwiftUI

// Enum de Botões da Calculadora

enum CalculatorButtons: String {
    case one, two, three, four, five, six, seven, eight, nine, zero, decimal
    case divide, multiply, minus, plus, equals
    case ac, plusMinus, porcent

    var title: String {
        switch self {
        case .zero: return "0"
        case .decimal: return "."
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .equals: return "="
        case .plus: return "+"
        case .minus: return "-"
        case .multiply: return "×"
        case .divide: return "÷"
        case .ac: return "AC"
        case .plusMinus: return "+/-"
        case .porcent: return "%"
        }
    }

    var systemImageName: String? {
        switch self {
        case .multiply: return "multiply"
        case .divide: return "divide"
        case .plus: return "plus"
        case .minus: return "minus"
        case .equals: return "equal"
        case .plusMinus: return "plus.forwardslash.minus"
        default: return nil
        }
    }

    var background: Color {
        switch self {
        case .decimal, .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            return Color(.darkGray)
        case .plus, .minus, .multiply, .divide, .equals:
            return Color(.orange)
        case .ac, .plusMinus, .porcent:
            return Color(.gray)
        }
    }
}


// global state of the app
// you can treat this as the Global Application State
class GlobalEnvironment: ObservableObject {
    @Published var display = ""
    
    func CaculatorButtonTapped(_ button: CalculatorButtons) {
        
        switch button {
            
        case .ac:
            display = "" // clear all
            
        case .plus, .minus, .multiply, .divide:
            // display.last take the last char of the string (shows what user's typing)
            
            if let last = display.last, "+-×÷".contains(last) {
                return
            }// verify if the string isnt empty and dont let you use two operators
            
            display.append(" \(button.title) ")// if everything's normal, it add normally
            
        case .equals:
            calculateResult()
            
        default:
            display.append(button.title)
        }
    }
    
    // func to calculate result
    private func calculateResult() {
        let expression = display
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "%", with: "*0.01")
        
        /* Format the numbers to be compatible with NSExpression
         the framework Foundation, calculate the math expression of a string ("5 + 3") */
        
        var modifiedComponents: [String] = [] // create an empty array to store each part
        
        let parts = expression.components(separatedBy: " ") // split the expression by spaces
        
        for i in parts {
            if let _ = Double(i) {
                // if it's a number
                if i.contains(".") {
                    modifiedComponents.append(i) // keep it as it is
                } else {
                    modifiedComponents.append( i + ".0") // add ".0" to make it a decimal
                }
            } else {
                // if it's an operator like +, -, *, /
                modifiedComponents.append(i)
            }
        }
        
        let modifiedExpression = modifiedComponents.joined(separator: " ") // put everything back together as a string
        // calculating modifiedExpression
        let exp: NSExpression = NSExpression(format: modifiedExpression)
        
        // as? NSNumber convertendo para numero
        if let result = exp.expressionValue(with: nil, context: nil) as? NSNumber {
            display = formatResult(result.doubleValue)
        } else {
            display = "Erro"
        }
    }
    
    // Formats the result (without unnecessary decimal places)
    private func formatResult(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value)) // remove ".0" if it's an integer
        } else {
            return String(value)
        }
    }
}

//ContentView
struct ContentView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    @State private var animateResult = false  // animation control

    let buttons: [[CalculatorButtons]] = [
        [.ac, .plusMinus, .porcent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four , .five, .six, .minus],
        [.one, .two, .three,  .plus],
        [.zero, .decimal, .equals]
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 15/255, green: 15/255, blue: 15/255)
                .ignoresSafeArea(edges: .all)
            
            VStack {
                
                // Display
                HStack {
                    Spacer()
                    Text(env.display)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading)
                        .scaleEffect(animateResult ? 1.10 : 1.0)  // grow the animation while animating
                        .opacity(animateResult ? 0.8 : 1.0) // decrease opacity while animating
                        .rotationEffect(.degrees(animateResult ? 2 : 0)) // gentle rotation
                        .shadow(color: animateResult ? .orange : .clear, radius: 5) // shadow effect
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: animateResult) // spring effect
                }
                .padding()

                // keyboard
                ForEach(buttons, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { button in
                            CalculatorButtonView(button: button, animateResult: $animateResult)
                        }
                    }
                }
            }
        }
    }
}

// Calculator button View
struct CalculatorButtonView: View {
    
    var button: CalculatorButtons
    @EnvironmentObject var env: GlobalEnvironment
    @Binding var animateResult: Bool
    
    var body: some View {
        Button(action: {
            self.env.CaculatorButtonTapped(button)

            // animation starts when " = " is pressed
            if button == .equals {
                self.animateResult = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.animateResult = false
                }
            }
        }) {
            
            ZStack {
                if let imageName = button.systemImageName {
                    Image(systemName: imageName)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                } else {
                    Text(button.title)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            .frame(
                width: buttonWidth(button: button),
                height: (UIScreen.main.bounds.width - 5 * 12) / 4
            )
            .background(button.background)
            .cornerRadius(buttonWidth(button: button))
            .shadow(radius: 15)
        }
    }

    private func buttonWidth(button: CalculatorButtons) -> CGFloat {
        if button == .zero {
            return (UIScreen.main.bounds.width - 4 * 12) / 4 * 2
        }
        return (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}


#Preview {
    ContentView().environmentObject(GlobalEnvironment())
}
