//
//  TabDesignView.swift
//  FoodDetector
//
//  Created by 강다연 on 2021/10/11.
//

import SwiftUI

struct TabDesignView: View {
    var body: some View {
        TabView{
            HomeView(calendar: Calendar(identifier: .gregorian))
                .tabItem{
                    Text("HOME")
                    Image(systemName: "house")
                }
                .navigationBarHidden(true)
            AnalyzeView()
                .tabItem{
                    Text("ANALYZE")
                    Image(systemName: "doc.text.below.ecg")
                }
                .navigationBarHidden(true)
            CameraView()
                .tabItem{
                    Text("CAMERA")
                    Image(systemName: "camera")
                }
                .navigationBarHidden(true)
            CommunityView()
                .tabItem{
                    Text("COMMUNITY")
                    Image(systemName: "person.2.circle")
                }
                .navigationBarHidden(true)
            ProfileView()
                .tabItem{
                    Text("PROFILE")
                    Image(systemName: "person.circle")}
                .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct TabDesignView_Previews: PreviewProvider {
    static var previews: some View {
        TabDesignView()
    }
}
