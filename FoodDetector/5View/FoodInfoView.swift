//
//  SwiftUIView.swift
//  FoodDetector
//
//  Created by 김세연 on 2021/12/05.
//

import SwiftUI




struct FoodInfoView: View {
    @State var FoodList: [foodNutritionResult] =
        [FoodDetector.foodNutritionResult(status_code: 1, id: "12011008", name: "배추김치", nutrition: [FoodDetector.FoodNutritionInfo(key: "calorie", value: 10.66), FoodDetector.FoodNutritionInfo(key: "carbohydrate", value: 1.27), FoodDetector.FoodNutritionInfo(key: "protein", value: 0.68), FoodDetector.FoodNutritionInfo(key: "fat", value: 0.31), FoodDetector.FoodNutritionInfo(key: "sugar", value: 0.95), FoodDetector.FoodNutritionInfo(key: "salt", value: 123.03), FoodDetector.FoodNutritionInfo(key: "saturated_fat", value: 0.02)]),
         FoodDetector.foodNutritionResult(status_code: 1, id: "11013007", name: "시금치나물", nutrition: [FoodDetector.FoodNutritionInfo(key: "calorie", value: 34.28), FoodDetector.FoodNutritionInfo(key: "carbohydrate", value: 1.68), FoodDetector.FoodNutritionInfo(key: "protein", value: 1.87), FoodDetector.FoodNutritionInfo(key: "fat", value: 2.23), FoodDetector.FoodNutritionInfo(key: "sugar", value: 0.05), FoodDetector.FoodNutritionInfo(key: "salt", value: 68.12), FoodDetector.FoodNutritionInfo(key: "saturated_fat", value: 0.2)]),
         FoodDetector.foodNutritionResult(status_code: 1, id: "1011011", name: "쌀밥", nutrition: [FoodDetector.FoodNutritionInfo(key: "calorie", value: 315.0), FoodDetector.FoodNutritionInfo(key: "carbohydrate", value: 70.0), FoodDetector.FoodNutritionInfo(key: "protein", value: 5.0), FoodDetector.FoodNutritionInfo(key: "fat", value: 1.5), FoodDetector.FoodNutritionInfo(key: "sugar", value: 0.0), FoodDetector.FoodNutritionInfo(key: "salt", value: 15.0), FoodDetector.FoodNutritionInfo(key: "saturated_fat", value: 0.0)]),
         FoodDetector.foodNutritionResult(status_code: 1, id: "4012001", name: "근대된장국", nutrition: [FoodDetector.FoodNutritionInfo(key: "calorie", value: 38.84), FoodDetector.FoodNutritionInfo(key: "carbohydrate", value: 2.71), FoodDetector.FoodNutritionInfo(key: "protein", value: 3.49), FoodDetector.FoodNutritionInfo(key: "fat", value: 1.56), FoodDetector.FoodNutritionInfo(key: "sugar", value: 3.31), FoodDetector.FoodNutritionInfo(key: "salt", value: 1304.10), FoodDetector.FoodNutritionInfo(key: "saturated_fat", value: 0.21)])
    ]
    
    @State var size = [String](repeating: "1", count: 10)
    
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
    
    @State var total : [FoodNutritionInfo] = [FoodDetector.FoodNutritionInfo(key: "calorie", value: 0.0), FoodDetector.FoodNutritionInfo(key: "carbohydrate", value: 0.0), FoodDetector.FoodNutritionInfo(key: "protein", value: 0.0), FoodDetector.FoodNutritionInfo(key: "fat", value: 0.0), FoodDetector.FoodNutritionInfo(key: "sugar", value: 0.0), FoodDetector.FoodNutritionInfo(key: "salt", value: 0.0), FoodDetector.FoodNutritionInfo(key: "saturated_fat", value: 0.0)]
    
    func getEat(idx:Int,value:Double,size:String)->String{
        var str = ""
        
        if size == ""{
            str = "0.00"
           // self.total[idx].value+=0.0
        }
        else{
            str = "\(String(format:"%.2f",value * Double(size)!))"
           // self.total[idx].value+=value * Double(size)!

        }
        return str
    }
    
    
    var body: some View {
        
        VStack (spacing: 0){
            //영양분 뷰
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(0..<self.total.count){ idx in
                        VStack{
                            Text("\(getKorean(str: self.total[idx].key))").bold()
                            Text("\(String(format:"%.2f",self.total[idx].value)) g")
                        }
                        .padding()
                        .frame(height: 60)
                        .backgroundColor(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15.0)
               
                    }
                }
            }
            
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment: .center){
                    ForEach(0..<FoodList.count){ i in
                        VStack(){
                            //음식
                            VStack(alignment: .leading){
                               // HStack{
                                Text("\(self.FoodList[i].name)").font(.title).fontWeight(.bold)
                                    .padding(.top,5)
                                //}
                                
                                Spacer()
                            HStack(alignment: .center) {
                                TextField("1",text: $size[i])
                                            .frame(width: 30)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: size[i], perform: {
                                        if size[i] == "" {
                                            self.total[0].value+=0.0
                                        }
                                        else {
                                            var cur = FoodList[i].nutrition[0].value * Double(size[i])!
                                            self.total[0].value += cur

                                        }
                                    })
                                            
                                       // .textFieldStyle(.RoundedBorder)
                                        Text("인분")
                                Spacer()
                                Spacer()
                                Text("\(getEat(idx: 0, value: FoodList[i].nutrition[0].value, size: size[i])) kcal")
                                       // .textFieldStyle(.RoundedBorder)

                                    //}
                                    
                               }
                            .padding(.bottom,5)

                            }
                            .padding()
                            .frame(height: 80)
                            .backgroundColor(.white)
                            .foregroundColor(.black)
                            .cornerRadius(15.0)
                            Spacer()
                            //영양분 뷰
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                                    ForEach(1..<self.FoodList[i].nutrition.count){ idx in
                                HStack{
                                    Text("\(getKorean(str: self.FoodList[i].nutrition[idx].key)) : ")
                                    if size[i] == ""{
                                        Text("0.00 g")
                                    }
                                    else{
                                        Text("\(getEat(idx: idx, value: FoodList[i].nutrition[idx].value, size: size[i])) g")
                                    }
                                }
                                .onChange(of: size[i], perform: {
                                    if size[i] == "" {
                                        self.total[idx].value+=0.0
                                    }
                                    else {
                                        var cur = FoodList[i].nutrition[idx].value * Double(size[i])!
                                        self.total[idx].value += cur

                                    }
                                })
                                
                                .padding()
                                .frame(height: 30)
                                .backgroundColor(.blue)
                                .foregroundColor(.black)
                                .cornerRadius(15.0)
            
                            }
                            }
                                
                            }
                            Spacer()
                    }
                        .padding(.all)
                         .frame(height: 150)
                        .backgroundColor(.gray)

                         .foregroundColor(.black)
                         .cornerRadius(15.0)
                    
                   
                    }
                 }
                    
                
                } //Vstack end
            .padding(.top, 5)
           
        }
            
        
    }
                            
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FoodInfoView(FoodList: [foodNutritionResult]())
    }
}
