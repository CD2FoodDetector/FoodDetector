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


struct FoodNutritionInfo:Codable{
    var key : String
    var value : Double
}


struct foodNutritionResult: Codable{
    
    var status_code: Int?
    var id: String
    var name: String
    
    var nutrition : [FoodNutritionInfo]
}
/*
struct Nutrition: Codable{
    var calorie : Float
    var protein: Float
    var carbohydrate: Float
    var fat:Float
    var sugar:Float
    var salt:Float
    var saturated_fat:Float
}
*/





struct DetectView: View {
    @Binding var image: UIImage
    @EnvironmentObject var cv: CommonVar
    //영양정보
    @State var foodList = [Food]()
    @State var foodNutritionList = [foodNutritionResult]()
    func values(_ str: String) -> [String] {
        let separators = CharacterSet(charactersIn: " ,\"")
        return str.components(separatedBy: separators)
    }
    

    func get_nutrition(id: String, serve_size: Float, size_unit:String) {
        
        guard let url = URL(string: "http://3.36.103.81:80/account/food_nutrition") else {
            print("Invalid url")
            return
        }
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["id":id, "size": serve_size, "size_unit":size_unit])
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data=data else{
                print("err at data")
                return
            }
            do{
                let res = try JSONDecoder().decode(foodNutritionResult.self, from: data)
                //should be called once
                foodNutritionList.append(res)
            } catch{
                
                print("에러")
                print(error)
        //        print(response ?? "response sample")
                return
            }
            print("decode!")
      
      //      print(foodNutritionList)
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
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data=data else{
                print("err at data")
                return
            }
            do{
                let res = try JSONDecoder().decode(DetectResult.self, from: data)
                foodList+=res.result
                
                for food in res.result {
                    //let foodInfo = values(food)
                    get_nutrition(id: food.food_id, serve_size: 1.0, size_unit: "인분")
                    
                }
            } catch{
                
                print("에러")
                print(error)
     //           print(response ?? "response sample")
                return
            }
            print("decode!")
          
        }.resume()
        
    }

    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false){
            VStack{
                
                Image(uiImage: image)
                //Image(systemName: "photo")
                //
                    .resizable()
                    .ignoresSafeArea(.all, edges: .top)
                    .cornerRadius(10.0)
                    .frame(height: 250)
                    .aspectRatio(contentMode: .fill)
                   // .padding(.bottom, 15)
                    .onAppear(perform: {
                        //connect server..
                     //   get_detect("user0001_0000007.jpg")
                    })

                //Spacer()
                //Text("총 칼로리 : \(MealNutrition.calorie) kcal").bold()
                FoodInfoView()
              
            }
            }
            VStack{
                Spacer()
                HStack(){
                    Spacer()
                    Button(action: {}, label: {
                        Text("식단 공유")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .padding(.vertical,10)
                            .padding(.horizontal,20)
                            .background(Color.black)
                            .clipShape(Capsule())
                        //.border(Color.black)
                        
                    })
                    .padding(.vertical, 10)
                    .padding(.horizontal, 5)
                }
                
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(false)
    }
    
}

struct NutritionView:View{
    
    var body: some View {
        Text("f")
    }
}



struct DetectView_Previews: PreviewProvider {
    static var previews: some View {
        DetectView(image: .constant(UIImage()))
    }
}
