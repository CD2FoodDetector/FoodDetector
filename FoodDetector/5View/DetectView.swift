//
//  DetectView.swift
//  FoodDetector
//
//  Created by 김세연 on 2021/12/04.
//

import SwiftUI

struct DetectResult: Codable{
    var status_code : Int
    var result: [Food]
}

struct Food:Codable{
    var coordinate:[Float]
    var p:Double
    var food_id: String
    var food_name: String
}

struct foodNutritionResult: Codable{
    var nutrition : Nutrition
    var id: String
    var name: String
    var status_code: Int
}

struct Nutrition: Codable{
    var calorie : Float
    var protein: Float
    var carbohydrate: Float
    var fat:Float
    var sugar:Float
    var salt:Float
    var saturated_fat:Float


}


struct DetectView: View {
    @Binding var image: UIImage
    @EnvironmentObject var cv: CommonVar
    //영양정보
    @State var total_calorie=0
    @State var total_carb=0
    @State var total_protein=0
    @State var total_fat=0
    
    @State var foodnameList = ["쌀밥","라면"]
    @State var foodidList = ["1011001","8011004"]
    
    func values(_ str: String) -> [String] {
        let separators = CharacterSet(charactersIn: " ,\"")
        return str.components(separatedBy: separators)
    }
    
    func get_nutrition(foodid: String, id: String, serve_size: Float, size_unit:String){
        
        guard let url = URL(string: "http://3.36.103.81:80/account/food_nutrition") else {
            print("Invalid url")
            return
        }
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["id":foodid, "size": serve_size, "size_unit":size_unit])
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let res = try! JSONDecoder().decode(foodNutritionResult.self, from: data!)
            //get info
        }.resume()
        
    }
    
    
    
    func get_detect(_ image_name: String){
        
        guard let url = URL(string: "http://3.36.103.81:80/account/detect") else {
            print("Invalid url")
            return
        }
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["img_name": image_name, "token": cv.token])
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let res = try! JSONDecoder().decode(DetectResult.self, from: data!)
            print("decode!")
            for i in res.result{
                foodnameList.append(i[6])
                foodnameList.append(i[5])

            }
            /*
            for food in res.result {
                //let foodInfo = values(food)
                foodnameList.append(food.food_name)
                foodnameList.append(food.food_id)
                print(food)
            }
 */
        }.resume()
        
    }

    
    var body: some View {
        ZStack {
            VStack{
                //Image(uiImage: load_img())
                Image(uiImage: image)
                    .resizable()
                    .frame(maxHeight: 200)
                    //.aspectRatio(contentMode: .fit)
                    .ignoresSafeArea(.container, edges: .all)
                    
                //Spacer()
                
                NavigationView{
                    List{
                        Section(header: Text("영양정보")){
                            HStack{
                                Text("탄수화물")
                                Spacer()
                                Text("\(total_carb) g")
                            }
                            HStack{
                                Text("단백질")
                                Spacer()
                                Text("\(total_protein) g")
                            }
                            HStack{
                                Text("지방")
                                Spacer()
                                Text("\(total_fat) g")
                            }
                    
                        
                        }
                    
                        Section(header: Text("음식")){
                            ForEach(foodnameList, id:\.self){ foodname in
                                HStack{
                                    Text(foodname)
                                }
                            }
                            
                    
                        }
                    
                    }
                    .navigationTitle(Text("총 칼로리 : \(total_calorie) kcal"))
                    .navigationBarTitleDisplayMode(.inline)
                }
                .ignoresSafeArea(.container, edges: .all)
            }
            
            VStack{
                Spacer()
                HStack(){
                    Spacer()
                    Button(action: {}, label: {
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
        
        .onAppear(perform: {
            get_detect("user0001_0000007.jpg")
            print(foodnameList)
            print(foodidList)
        })
    }
}

struct DetectView_Previews: PreviewProvider {
    static var previews: some View {
        DetectView(image: .constant(UIImage()))
    }
}
