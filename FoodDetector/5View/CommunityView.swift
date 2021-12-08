//
//  CommunityView.swift
//  FoodDetector
//
//  Created by 심민보 on 2021/12/05.
//

import SwiftUI
import Combine

struct Post {
    let id: Int
    let userName, text, profileImageName, imageName: String
}

struct CommunityImg: Codable{
    var img: [String]
    var user_id: [String]
    var datetime: [String]
    var status_code: Int
}

class Filter: ObservableObject {
    @Published
    var showSettings = false
    
    enum AmountOfCarbo: String, CaseIterable {
        case 많이, 보통, 적게
    }
    
    @Published
    var amountOfCarbo = AmountOfCarbo.많이
    
    enum AmountOfProtein: String, CaseIterable {
        case 많이, 보통, 적게
    }
    
    @Published
    var amountOfProtein = AmountOfProtein.많이
    
    enum AmountOfFat: String, CaseIterable {
        case 많이, 보통, 적게
    }
    
    @Published
    var amountOfFat = AmountOfFat.많이
    
    
    @Published
    var isDiabetes = false
}

struct PostView: View {
    let post: Post
    let screenWidth: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(uiImage: load_img("\(post.profileImageName).jpg"))
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                Text(post.userName).font(.headline)
                Image(systemName: "heart")
                    .padding(.leading, 150)
            }.padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 0))
            //Image(post.imageName)
            Image(uiImage: load_img(post.imageName))
                .resizable()
                .scaledToFill()
                .frame(width: 350, height: 250)
                .clipped()
            
            
            Text(post.text)
                .lineLimit(nil)
                .font(.system(size: 13, weight: .ultraLight))
                .padding(.leading, 16).padding(.trailing, 16).padding(.bottom, 16)
        }.listRowInsets(EdgeInsets())
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

struct CommunityView: View {
    @EnvironmentObject var cv: CommonVar
    @State var imgList: [String] = []
    @State var userList: [String] = []
    @State var dateList: [String] = []
    
    @State var posts: [Post] = []
    
    @ObservedObject var filter = Filter()
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                List {
                        ForEach(self.posts, id: \.id) {(post) in
                            PostView(post: post,screenWidth: geometry.size.width)
                        }
                    }
                    .navigationBarTitle(Text("커뮤니티"))
                    .navigationBarItems(trailing: Button(action: {
                                    self.filter.showSettings = true
                                }, label: {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                }))
                                    .sheet(isPresented: $filter.showSettings, content: {
                                        FilterView(filter: self.filter)
                                })
                
            }
            
            .onAppear(perform: {
                get_imgs_list("1231")
            })
            .onReceive(filter.$amountOfProtein, perform: { _ in
                var gcode: String = ""
                
                switch filter.amountOfCarbo.rawValue {
                case "많이":
                    gcode += "3"
                case "보통":
                    gcode += "2"
                case "적게":
                    gcode += "1"
                default:
                    gcode += "0"
                }
                
                switch filter.amountOfProtein.rawValue {
                case "많이":
                    gcode += "3"
                case "보통":
                    gcode += "2"
                case "적게":
                    gcode += "1"
                default:
                    gcode += "0"
                }
                
                switch filter.amountOfFat.rawValue {
                case "많이":
                    gcode += "3"
                case "보통":
                    gcode += "2"
                case "적게":
                    gcode += "1"
                default:
                    gcode += "0"
                }
                gcode += "2"
                print("onReceive. gcode = \(gcode)")
                get_imgs_list(gcode)
            })
            
        }
        
        
    }
        
    
    func get_imgs_list(_ gcode: String) {
        guard let url = URL(string: "http://3.36.103.81:80/account/community_img") else {
            print("Invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["gcode":gcode, "token": cv.token], options: [])
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let result = try! JSONDecoder().decode(CommunityImg.self, from: data!)
            imgList = result.img
            userList = result.user_id
            dateList = result.datetime
            
            posts = []
            for i in 0..<imgList.count {
                posts.append(Post(id: i, userName: userList[i], text: dateList[i], profileImageName: userList[i], imageName: imgList[i]))
            }
        }.resume()
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}


struct FilterView: View {
    @Environment(\.presentationMode)
    var presentationMode
    
    @ObservedObject var filter: Filter
    
    @State var amountOfCarbo = Filter.AmountOfCarbo.많이
    @State var amountOfProtein = Filter.AmountOfProtein.많이
    @State var amountOfFat = Filter.AmountOfFat.많이
    
    @State
    var isDiabetes = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("탄수화물")) {
                    Picker(selection: $amountOfCarbo, label: Text("Shape"), content: {
                        ForEach(Filter.AmountOfCarbo.allCases, id: \.self) { shape in
                            Text("\(shape.rawValue)")
                            .tag(shape)
                        }
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    
                }
                
                Section(header: Text("단백질")) {
                    Picker(selection: $amountOfProtein, label: Text("Shape"), content: {
                        ForEach(Filter.AmountOfProtein.allCases, id: \.self) { shape in
                            Text("\(shape.rawValue)")
                            .tag(shape)
                        }
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    
                }
                
                Section(header: Text("지방")) {
                    Picker(selection: $amountOfFat, label: Text("Shape"), content: {
                        ForEach(Filter.AmountOfFat.allCases, id: \.self) { shape in
                            Text("\(shape.rawValue)")
                            .tag(shape)
                        }
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    
                }
                
                Section(header: Text("Other Settings")) {
                    Toggle(isOn: $isDiabetes, label: {
                        Text("당뇨 환자 식단")
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .font(.body)
                    })
                }
            }
            .navigationBarTitle("Filter")
            .navigationBarItems(trailing: Button(action: {
                self.filter.amountOfCarbo = self.amountOfCarbo
                self.filter.amountOfProtein = self.amountOfProtein
                self.filter.amountOfFat = self.amountOfFat
                self.filter.isDiabetes = self.isDiabetes
                
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("완료")
            }))
        }
        .onAppear(perform: {
            self.amountOfCarbo = self.filter.amountOfCarbo
            self.amountOfProtein = self.filter.amountOfProtein
            self.amountOfFat = self.filter.amountOfFat
            self.isDiabetes = self.filter.isDiabetes
        })
    }
}
