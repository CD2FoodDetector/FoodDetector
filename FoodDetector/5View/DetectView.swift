//
//  DetectView.swift
//  FoodDetector
//
//  Created by 김세연 on 2021/12/04.
//

import SwiftUI

struct DetectView: View {
    var body: some View {
        VStack{
            //UIimage
            Text("Image")
            
            Spacer()
            
            
            NavigationView{
                List{
                    Section(header: Text("영양정보")){
                    
                        Text("탄수화물")
                        Text("단백질")
                    
                    }
                
                    Section(header: Text("음식")){
                
                        Text("밥")
                        Text("라면")
                        Text("배추김치")
                
                    }
                
                }
                .navigationBarTitle(Text("총 칼로리 : kcal"))
            }
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("식단 공유")
            })
        }
        
        
    }
}

struct DetectView_Previews: PreviewProvider {
    static var previews: some View {
        DetectView()
    }
}
