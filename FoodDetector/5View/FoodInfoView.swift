//
//  SwiftUIView.swift
//  FoodDetector
//
//  Created by 김세연 on 2021/12/05.
//

import SwiftUI




struct FoodInfoView: View {
    @State var FoodList: [foodNutritionResult] = [FoodDetector.foodNutritionResult(status_code: Optional(1), id: "12011008", name: "배추김치", nutrition: [FoodDetector.FoodNutritionInfo(key: "calorie", value: 10.66), FoodDetector.FoodNutritionInfo(key: "carbohydrate", value: 1.27), FoodDetector.FoodNutritionInfo(key: "protein", value: 0.68), FoodDetector.FoodNutritionInfo(key: "fat", value: 0.31), FoodDetector.FoodNutritionInfo(key: "sugar", value: 0.95), FoodDetector.FoodNutritionInfo(key: "salt", value: 123.03), FoodDetector.FoodNutritionInfo(key: "saturated_fat", value: 0.02)]), FoodDetector.foodNutritionResult(status_code: Optional(1), id: "11013007", name: "시금치나물", nutrition: [FoodDetector.FoodNutritionInfo(key: "calorie", value: 34.28), FoodDetector.FoodNutritionInfo(key: "carbohydrate", value: 1.68), FoodDetector.FoodNutritionInfo(key: "protein", value: 1.87), FoodDetector.FoodNutritionInfo(key: "fat", value: 2.23), FoodDetector.FoodNutritionInfo(key: "sugar", value: 0.05), FoodDetector.FoodNutritionInfo(key: "salt", value: 68.12), FoodDetector.FoodNutritionInfo(key: "saturated_fat", value: 0.2)])]
    
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
            str = "0.00 g"
            total[idx].value+=0.0
        }
        else{
            str = "\(String(format:"%.2f",value * Double(size)!)) g"
            total[idx].value+=value * Double(size)!

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
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9803921569, green: 0.6470588235, blue: 0.3764705882, alpha: 1)), Color(#colorLiteral(red: 0.9882352941, green: 0.6705882353, blue: 0.6039215686, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
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
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
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
                            
                            .padding()
                            .frame(height: 30)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9803921569, green: 0.6470588235, blue: 0.3764705882, alpha: 1)), Color(#colorLiteral(red: 0.9882352941, green: 0.6705882353, blue: 0.6039215686, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .foregroundColor(.black)
                            .cornerRadius(15.0)
                        
                        }
                        }
                            
                        }
                        Spacer()
                }
                    .padding(.all)
                     .frame(height: 150)
                     .background(
                         LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)), Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                     )
                     .foregroundColor(.black)
                     .cornerRadius(15.0)
                
                // .onAppear(perform: loadData)
                }
             }
                
            
            } //Vstack end
        .padding()
       
    }
    }
                            
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FoodInfoView(FoodList: [foodNutritionResult]())
    }
}
