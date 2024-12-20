//
//  AnswerCardView.swift
//  FrontIOS
//
//  Created by guesmiFiras on 28/11/2024.
//

import SwiftUI

struct AnswerCardView: View {
    let answer: Answer
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(answer.text)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .white : Color(hex: "#4f3422"))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(isSelected ? Color(hex: "#4f3422") : Color(hex: "#f7e6d5"))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .onHover { hovering in
                        withAnimation {
                            if hovering {
                                // Hover effect
                                _ = isSelected ? Color(hex: "#4f3422") : Color(hex: "#e0cbb8")
                            }
                        }
                    }
                    .onTapGesture {
                        action()
                    }
            }
        }
    }
        }
