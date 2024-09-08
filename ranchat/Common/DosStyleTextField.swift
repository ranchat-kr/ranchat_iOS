//
//  DosStyleTextField.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import SwiftUI

struct DosStyleTextField: View {
    let hint: String
    @Binding var text: String
    @State private var textFieldHeight: CGFloat = 0
    @State private var isVisible = false
    private var cursorWidth: CGFloat
    private var cursorHeight: CGFloat?
    private var cursorColor: Color?
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    init(hint: String, text: Binding<String>, cursorWidth: CGFloat) {
        self.hint = hint
        self._text = text
        self.cursorWidth = cursorWidth
    }
    
    init(hint: String, text: Binding<String>, cursorWidth: CGFloat, cursorHeight: CGFloat?) {
        self.hint = hint
        self._text = text
        self.cursorWidth = cursorWidth
        self.cursorHeight = cursorHeight
    }
    
    init(hint: String, text: Binding<String>, cursorWidth: CGFloat, cursorHeight: CGFloat?, cursorColor: Color?) {
        self.hint = hint
        self._text = text
        self.cursorWidth = cursorWidth
        self.cursorHeight = cursorHeight
        self.cursorColor = cursorColor
    }
    
    var body: some View {
        ZStack (alignment: .leading) {

                TextField("dd", text: $text)
                    .background(GeometryReader {proxy in
                        Color.clear
                            .onAppear {
                                textFieldHeight = proxy.size.height
                            }
                    })
    
            if let height = cursorHeight, let color = cursorColor {
                Rectangle()
                    .fill(isVisible ? color : .clear)
                    .frame(width: 5, height: height)
                    .onReceive(timer) { _ in

                            isVisible.toggle()

                    }
            } else if let height = cursorHeight {
                Rectangle()
                    .fill(isVisible ? .white : .clear)
                    .frame(width: 5, height: height)
                    .onReceive(timer) { _ in
                       
                            isVisible.toggle()
                       
                    }
            } else if let color = cursorColor {
                Rectangle()
                    .fill(isVisible ? color : .clear)
                    .frame(width: 5, height: textFieldHeight)
                    .onReceive(timer) { _ in
                       
                            isVisible.toggle()
                       
                    }
            } else {
                Rectangle()
                    .fill(isVisible ? .white : .clear)
                    .frame(width: 5, height: textFieldHeight)
                    .onReceive(timer) { _ in
                        
                            isVisible.toggle()
                        
                    }
            }
        }
    }
}

#Preview {
    DosStyleTextField(hint: "dd", text: .constant(""), cursorWidth: 5)
}
