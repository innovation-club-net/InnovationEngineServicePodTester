//
//  CompactFormItemView.swift
//  PodTester
//
//  Created by Fred on 26.12.22.
//

import SwiftUI

struct CompactFormFieldView: View {
    
    var header: String?
    @Binding var text: String
    var isEditable: Bool = false
    var footer: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let header = header {
                Text(header)
                    .font(.custom("Mulish-Regular", size: 15, relativeTo: .subheadline))
                    .foregroundColor(.secondary)
            }
            if isEditable {
                TextField(header ?? "", text: $text)
                    .padding(10)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text(text)
                    .padding(.horizontal, 10)
            }
            if let footer = footer {
                Text(footer)
                    .font(.custom("Mulish-Italic", size: 13, relativeTo: .footnote))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CompactFormItemView_Previews: PreviewProvider {
    
    @State static var text = "Hello"
    
    static var previews: some View {
        CompactFormFieldView(header: "Text", text: $text)
    }
}
