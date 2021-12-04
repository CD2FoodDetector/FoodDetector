//
//  ProfileView.swift
//  FoodDetector
//
//  Created by 강다연 on 2021/10/11.
//

import SwiftUI

struct ProfileImg: Codable{
    var img: [String]
}

 
struct ProfileView: View {
    @State var selectedTab: String = "square.grid.3x3"
    @State var imgList: [String] = []
    @Namespace var animation
    
    @EnvironmentObject var cv: CommonVar
    
    let gridlayout = [
        GridItem(.flexible(minimum: 40), spacing: 1),
        GridItem(.flexible(minimum: 40), spacing: 1),
        GridItem(.flexible(minimum: 40), spacing: 1)
    ]
    
    var body: some View {
        VStack (){
            VStack {
                HStack(spacing: 40){
                    Text("us")
                        .fontWeight(.light)
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(20)
                        .background(Color.purple)
                        .clipShape(Circle())
                        .padding(2)
                        .background(Color.white)
                        .clipShape(Circle())
                        .onAppear(perform: {
                            get_imgs_list("user0001")
                            print(imgList)
                        })
                    
                    VStack{
                        Text("0")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Likes")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack{
                        Text("\(imgList.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Meals")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                        
                }
                .padding(40)
                
                VStack(alignment: .leading, spacing: 4, content: {
                    Text("Profile")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("_user0001")
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    Text("사용자 소개가 들어가는 부분입니다.                          ")
                    
                    HStack{
                        Button(action: {}, label: {
                            Text("프로필 편집")
                                .foregroundColor(.blue)
                                .padding(.vertical, 6)
                                .padding(.horizontal)
                                .background(
                                    Capsule()
                                        .stroke(Color.blue)

                                )
                        })
                            .padding(.top, 10)
                        
                        Button(action: {}, label: {
                            Text("목표 수정")
                                .foregroundColor(.blue)
                                .padding(.vertical, 6)
                                .padding(.horizontal)
                                .background(
                                    Capsule()
                                        .stroke(Color.blue)

                                )
                        })
                            .padding(.top, 10)
                            .padding(.leading, 10)
                        
                        
                    }
                    
                    
                })
                    .padding(.horizontal, 13)
                
                
                // Seg Bar
                HStack(spacing: 0){
                    SegButton(image: "square.grid.3x3", isSystemImage: true, animation: animation, selectedTab: $selectedTab)
                    
                    SegButton(image: "graduationcap", isSystemImage: true, animation: animation, selectedTab: $selectedTab)
                    
                    
                }
                .frame(height: 50, alignment: .bottom)
            }
            
            ScrollView(.vertical, showsIndicators: false, content: {
                if selectedTab == "square.grid.3x3" {
                    // TODO: 지금까지 올린 식단 Grid 표시
                    ScrollView {
                        LazyVGrid(columns: gridlayout, spacing: 3, content: {
                            ForEach(imgList, id: \.self) { imgName in
                                
                                Image(uiImage: load_img(imgName))
                                    .resizable()
                                    .frame(width: 128, height: 128) // iPhone12 기준 - 다른 기종 테스트 안했습니다.
                                    .clipped()
                                    
                            }
                        })
                    }
                }
                else{
                    Text("Select2")
                    // TODO: 당근마켓 뱃지 같은거?
                }
            })
            
        }
    }
    
    func get_imgs_list(_ id: String) {
        guard let url = URL(string: "http://3.36.103.81:80/account/profile_meal") else {
            print("Invalid url")
            return
        }
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["id":id, "token": cv.token], options: [])
        print("in Profile. token = \(cv.token)")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let result = try! JSONDecoder().decode(ProfileImg.self, from: data!)
            imgList = result.img
        }.resume()
         
    }
    
    func load_img(_ name: String) -> UIImage {
        do{
            guard let url = URL(string: "http://3.36.103.81:80/images/\(name)") else{
                return UIImage()
            }
            
            let data: Data = try Data(contentsOf: url)
            
            return UIImage(data: data) ?? UIImage()
        } catch{
        }
        return UIImage()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct SegButton: View {
    
    var image: String
    var isSystemImage: Bool
    var animation: Namespace.ID
    @Binding var selectedTab: String
    
    var body: some View{
        
        Button(action: {
            withAnimation(.easeInOut) {
                selectedTab = image
            }
            
        }, label: {
            VStack(spacing: 12){
                
                (
                    isSystemImage ? Image(systemName: image) : Image(image)
                )
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(selectedTab == image ? .primary : .gray)
                
                ZStack{
                    if selectedTab == image {
                        Rectangle()
                            .fill(Color.primary)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                    else {
                        Rectangle()
                            .fill(Color.clear)
                    }
                }
                .frame(height: 1)
            }
        })
    }
}
