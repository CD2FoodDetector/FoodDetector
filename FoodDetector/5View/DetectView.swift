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

struct Food:Codable, Hashable{
    var coordinate:[Float]
    var p:Double
    var food_id: String
    var food_name: String
}


struct FoodNutritionInfo:Codable{
    var key : String
    var value : Double
}

struct foodNutritionResult: Codable {
    
    var status_code: Int?
    var id: String
    var name: String
    
    var nutrition : [FoodNutritionInfo]
    
    private enum CodingKeys: String, CodingKey {
        case status_code, id, name, nutrition
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? values.decode(String.self, forKey: .id)) ?? "no id"
        name = (try? values.decode(String.self, forKey: .name)) ?? "no name"
        nutrition = (try? values.decode([FoodNutritionInfo].self, forKey: .nutrition)) ?? []
        status_code = (try? values.decode(Int.self, forKey: .status_code)) ?? -1
    }
}

struct AddMeal: Codable{
    var status_code : Int
}

struct SearchFood: Codable{
    var result : [foodNutritionResult]
    var resultNum : Int
}

struct DetectView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    
    @Binding var image: UIImage
    @EnvironmentObject var cv: CommonVar

    //영양정보
    @State var foodList = [Food]()
    @State var foodNutritionList = [foodNutritionResult]()
    
    @State var total : [FoodNutritionInfo] = [FoodDetector.FoodNutritionInfo(key: "calorie", value: 0.0), FoodDetector.FoodNutritionInfo(key: "carbohydrate", value: 0.0), FoodDetector.FoodNutritionInfo(key: "protein", value: 0.0), FoodDetector.FoodNutritionInfo(key: "fat", value: 0.0), FoodDetector.FoodNutritionInfo(key: "sugar", value: 0.0), FoodDetector.FoodNutritionInfo(key: "salt", value: 0.0), FoodDetector.FoodNutritionInfo(key: "saturated_fat", value: 0.0)]
    @State var size = [String](repeating: "1", count: 10)
    @State var newSize = [String](repeating: "1", count: 10)
    @State var detect_cnt = 0
    @State var food_search_sheet = false
    @State var search_foods = [foodNutritionResult]()
    @State var search_foods_num = 0
    @State var food_name = ""
    
    
    func getKorean(str: String)->String{
        switch(str){
        case "fat" : return "지방"
        case "calorie" : return "칼로리"
        case "carbohydrate" : return "탄수화물"
        case "protein" : return "단백질"
        case "sugar" : return "당류"
        case "salt" : return "나트륨"
        case "saturated_fat" : return "포화지방"
        default:
            return "default"
        }
    }
    

    
    func getEat(idx:Int,value:Double,size:String)->String{
        var str = ""
        
        if size == ""{
            str = "0.00"
           // self.total[idx].value+=0.0
        }
        else{
            str = "\(String(format:"%.2f",value * (Double(size) ?? 0.0)))"
           // self.total[idx].value+=value * Double(size)!

        }
        return str
    }
    
    
    func add_meal(id: String) {
        
        guard let url = URL(string: "http://3.36.103.81:80/account/meal_add") else {
            print("Invalid url")
            return
        }
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["id":id, "image_name":"user0001_0000007.jpg", "calories_total": total[0].value,"carbo_total": total[1].value,"protein_total": total[2].value,"fat_total": total[3].value,"sugar_total": total[4].value,"salt_total": total[5].value,"saturated_fat_total": total[6].value])
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
                if res.status_code == 1{
                    print("meal add success!")
                }
                else{
                    print("status code err")
                    print(res)
                }
            } catch{
                
                print("meal add 에러")
                print(error)
        
                return
            }
      //      print(foodNutritionList)
        }.resume()
        
            
        return
    }
    
    func search_food(name: String) {
        
        guard let url = URL(string: "http://3.36.103.81:80/account/search_food") else {
            print("Invalid url")
            return
        }
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["name":name])
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data=data else{
                print("err at data")
                return
            }
            do{
                let res = try JSONDecoder().decode(SearchFood.self, from: data)
                //should be called once
                print("search_food decode!")
                search_foods = res.result
                search_foods_num = res.resultNum
                
            } catch{
                
                print("search_food 에러")
                print(error)
        
                return
            }
      //      print(foodNutritionList)
        }.resume()
        
            
        return
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
                if res.status_code == 1{
                    foodNutritionList.append(res)
                }
                else{
                    print("status code err")
                    print("id:\(id), size: \(serve_size)")
                    print(res)
                }
            } catch{
                
                print("nutrition 에러")
                print("id:\(id), size: \(serve_size)")
                print(error)
        
                return
            }
            print("food nutrition decode!")
      
      //      print(foodNutritionList)
        }.resume()
        
        return
            

    }
    
    func get_detect(_ image_name: String){
        if detect_cnt > 0{
            print("!! detect api is already called !!")
            return
        }
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
                
                print("detect 성공")
     //           print(res)
                for food in res.result {
                    //let foodInfo = values(food)
                    if res.status_code == 1 {
                        if food.food_id.hasPrefix("0") {
                            let startIdx: String.Index = food.food_id.index(food.food_id.startIndex, offsetBy: 1)
                            get_nutrition(id: String(food.food_id[startIdx...]), serve_size: 1.0, size_unit: "인분")
                        }
                        else{
                            get_nutrition(id: food.food_id, serve_size: 1.0, size_unit: "인분")
                        }
                    }
                    else{
                        print("ERROR @ receiving detect api : wrong status code : \(res.status_code)")
                    }
                    
                }
            } catch{
                
                print("detect 에러")
                print(error)
     //           print(response ?? "response sample")
                return
            }
    //        print("detect decode!")
            detect_cnt+=1
          
        }.resume()
        
    }

    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    ZStack{
                        Image(uiImage: image)
                        //Image(systemName: "photo")
                            .resizable()
                            .ignoresSafeArea(.all, edges: .top)
                            .cornerRadius(10.0)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .onAppear(perform: {
                                //connect server..
                                get_detect("user0001_0000007.jpg")
                            })
                        // 음식 정보 띄우기
                        
                        ForEach(foodList, id: \.self){ food in
                            VStack(alignment: .center, spacing: 0){
                                HStack(alignment:.center){
                                    let x:Float = food.coordinate[0]
                                    let y:Float = food.coordinate[1]
                                    Text("\(food.food_name.trimmingCharacters(in: .whitespacesAndNewlines))")
                                    .padding(.all,2)
                                    .background(Color.gray.opacity(0.5))
                                    .offset(x: CGFloat(x)*0.1, y: CGFloat(y)*0.1)
                                    .foregroundColor(.white)
                                        // .clipShape(Capsule())
                                    
                                    Spacer()
                                }
                                Spacer()
                            }
                            .onAppear(perform: {print("name : \(food.food_name) x: \(CGFloat(food.coordinate[0])*0.1), y: \(CGFloat(food.coordinate[1])*0.1)")})
                        }

                    }
              //      VStack (spacing: 0){
                        //영양분 뷰
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                ForEach(0..<total.count, id:\.self){ idx in
                                    VStack{
                                        Text("\(getKorean(str: total[idx].key))").bold()
                                        Text("\(String(format:"%.2f",total[idx].value)) \(idx == 0 ? "kcal": idx == 5 ? "mg":"g")")
                                    }
                                    .padding()
                                    .frame(height: 60)
                                    .background(Color.lightgray)
                                    .foregroundColor(.black)
                                    .cornerRadius(15.0)
                           
                                }
                            }
                        }
                        
                        ScrollView(.vertical, showsIndicators: false){
                            VStack(alignment: .center){
                                ForEach(0..<foodNutritionList.count, id:\.self){ i in
                                    VStack(){
                                        //음식
                                        VStack(alignment: .leading){
                                           // HStack{
                                            Text("\(foodNutritionList[i].name)").font(.title).fontWeight(.bold)
                                                .padding(.top,5)
                                            //}
                                            
                                            Spacer()
                                        HStack(alignment: .center) {
                                            TextField("1",text: $newSize[i],onCommit:{
                                                let actually : Double = (Double(newSize[i]) ?? 0.0 ) - (Double(size[i]) ?? 0.0)
                                                size[i] = newSize[i]
                                                for idx in total.indices {
                                                    total[idx].value += foodNutritionList[i].nutrition[idx].value*actually
                                                }
                                            })
                                                        .frame(width: 60)
                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                                
                                                        
                                                   // .textFieldStyle(.RoundedBorder)
                                            Text("인분")
                                            Spacer()
                                            Spacer()
                                            Text("\(getEat(idx: 0, value: foodNutritionList[i].nutrition[0].value, size: size[i])) kcal")
                                                .onAppear{
                                                    for idx in total.indices {
                                                        self.total[idx].value+=foodNutritionList[i].nutrition[idx].value * (Double(size[i]) ?? 0.0)
                                                    }

                                                    
                                                }
                                                
                                           }
                                        .padding(.bottom,5)

                                        }
                                        .padding()
                                        .frame(height: 80)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(15.0)
                                        Spacer()
                                        //영양분 뷰
                                        ScrollView(.horizontal, showsIndicators: false){
                                            HStack{
                                                ForEach(1..<foodNutritionList[i].nutrition.count, id:\.self){ idx in
                                            HStack{
                                                Text("\(getKorean(str: (foodNutritionList[i].nutrition[idx].key))) : ")
                                                if size[i] == ""{
                                                    Text("0.00 \(idx == 5 ? "mg":"g")")
                                                }
                                                else{
                                                    Text("\(getEat(idx: idx, value: (foodNutritionList[i].nutrition[idx].value), size: size[i])) \(idx == 5 ? "mg":"g")")
                                                }
                                            }
                                            .padding()
                                            .frame(height: 30)
                                            .background(Color.gray)
                                            .foregroundColor(.black)
                                            .cornerRadius(15.0)
                                            
                        
                                        }
                                        }
                                            
                                        }
                                        Spacer()
                                }
                                    //.padding(.all)
                                     .frame(height: 150)
                                    //.backgroundColor(.gray)
                                    .background(Color.lightgray)
                                     .foregroundColor(.black)
                                     .cornerRadius(15.0)
                                    .padding(.all)
                               
                                }
                             }
                                
                            
                   //         } //Vstack end
    
                       
                    }
                }
            
            }// scroll view end
            
            
            VStack{
                HStack{
                    Button(action : {
                        self.mode.wrappedValue.dismiss()
                      //  image = UIImage()
                    }){
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(.all,5)
                    }
                    Spacer()
                }

                Spacer()
                HStack(){
                    Button(action: {
                        self.food_search_sheet.toggle()
                    }, label: {
                        Image(systemName: "plus.magnifyingglass")
                     //       .resizable()
                     //       .frame(width: 10, height: 10)
                            .foregroundColor(.white)
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            .background(Color.black)
                            .clipShape(Circle())
                        //.border(Color.black)
                        
                    })
                    .padding(.vertical, 10)
                    .padding(.horizontal, 5)
                    
                    
                    Spacer()
                    Button(action: {
                        add_meal(id:"user0001")
                        self.mode.wrappedValue.dismiss()
                    }, label: {
                        Text("식단 저장")
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
            .sheet(isPresented: $food_search_sheet){
                VStack{
                    
                    TextField("추가할 음식을 입력해주세요..",text: $food_name,onCommit:{
                        search_food(name:food_name)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    if search_foods_num == 0{
                        Spacer()
                        Text("음식을 찾을 수 없습니다. 다시 입력해 주세요.")
                        Spacer()
                    }
                    else{
                        Text("탭해서 음식을 추가하세요.")
                        Divider()
                        List{
                            ForEach(0..<search_foods.count, id:\.self){ index in
                                Text("\(search_foods[index].name)")
                                    .fontWeight(.semibold)
                                    .padding(.vertical,10)
                                    .padding(.horizontal,20)
                                    .onTapGesture{
                                        // food add
                                        foodNutritionList.append(search_foods[index])
                                        
                                        self.food_search_sheet.toggle()
                                    }
                            }

                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)

    }
    
}

struct DetectView_Previews: PreviewProvider {
    static var previews: some View {
        DetectView(image: .constant(UIImage()))
    }
}
