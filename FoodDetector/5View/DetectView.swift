//
//  DetectView.swift
//  FoodDetector
//
//  Created by 김세연 on 2021/12/04.
//

import SwiftUI

struct DetectView: View {
    @Binding var image: UIImage
    @Binding var showDetectView : Bool

    var body: some View {
        ZStack {
            VStack{
                //Image(uiImage: load_img())
                Image(uiImage: image)
                    .resizable()
                    .ignoresSafeArea(.all, edges: .all)

                //Spacer()
                
                
                NavigationView{
                    List{
                        Section(header: Text("영양정보")){
                        
                            Text("탄수화물")
                            Text("단백질")
                            Text("밥")
                            Text("라면")
                            Text("배추김치")
                            Text("밥")
                            Text("라면")
                            Text("배추김치")
                    
                        
                        }
                    
                        Section(header: Text("음식")){
                    
                            Text("밥")
                            Text("라면")
                            Text("배추김치")
                            Text("밥")
                            Text("라면")
                            Text("배추김치")
                            Text("밥")
                            Text("라면")
                            Text("배추김치")
                    
                    
                        }
                    
                    }
                    .navigationBarTitle(Text("총 칼로리 : kcal"))
                }

            }
            
            VStack{
                Spacer()
                HStack(){
                    Spacer()
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("식단 공유")
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                            .background(Color.lightgray)
                            .clipShape(Capsule())
                            //.border(Color.black)

                    })
                    .padding(.vertical, 10)
                    .padding(.horizontal, 5)
                }
                
            }
        }
        
        
    }
}

struct DetectView_Previews: PreviewProvider {
    static var previews: some View {
        DetectView(image: .constant(UIImage()), showDetectView: .constant(true))
    }
}
