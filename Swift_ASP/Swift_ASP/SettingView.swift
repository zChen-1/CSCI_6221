//
//  SettingView.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/11.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    // My dashboard button
                    Button(action: {
                        //self.navigateToContentView.toggle()
                    }) {
                        Image(systemName: "person.crop.circle")
                        Text("My dashboard")
                        Spacer()
                    }
                    .foregroundColor(.white)
                    
                    // Setting button
                    Button(action: {
                        //navigateToSettingView.toggle()
                        print("setting button works")
                    }) {
                        Image(systemName: "gearshape.fill")
                        Text("Setting")
                    }
                    .foregroundColor(.white)
                }
                .padding()
                .cornerRadius(10)
                .shadow(radius: 5)
                Spacer()
            }
            .background(
                Image("GW color")
                    .resizable()
                    .scaledToFill()
                    .clipped())
            
        }
        .navigationTitle("Setting")
    }
}

#Preview {
    SettingView()
}
