//
//  AnalyzeView.swift
//  FoodDetector
//
//  Created by 강다연 on 2021/10/11.
//

import SwiftUICharts
import SwiftUI

struct AnalyzeView: View {
    
    @State var selected = 0
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    var colors = [Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1))]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators:false) {
                VStack{
                    
                    HStack{
                        Text("Analyze")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer(minLength: 0)
                        
                        Button(action: {}) {
                            //Text("menu")
                        } }
                        .padding()
                    
                    
                    // Bar Chart
                    VStack(alignment: .leading, spacing: 25){
                        Text("Daily Calorie")
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                        
                        HStack(spacing: 15){
                            ForEach(workout_Data){work in
                                
                                //Bars
                                
                                VStack{
                                    VStack{
                                        Spacer(minLength: 0)
                                        if selected == work.id{
                                            Text(getHrs(value: work.Calorie))
                                                                                        .foregroundColor(Color(#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)))
                                                                                        .padding(.bottom, 5)
                                        }
                                        
                                        RoundedShape()
                                            .fill(LinearGradient(gradient: .init(colors: selected == work.id ? colors : [Color.black.opacity(0.06)]), startPoint: .top, endPoint: .bottom))
                                            .frame(height: getHeight(value:
                                                                        work.Calorie) / 22)
                                    }
                                    .frame(height: 220)
                                    .onTapGesture{
                                        withAnimation(.easeOut){
                                            selected = work.id
                                        }
                                    }
                                    Text(work.day)
                                        .font(.caption)
                                    
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.06))
                    .cornerRadius(10)
                    .padding()
                    
                    HStack{
                        Text("Statistics")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer(minLength: 0)
                        
                        Button(action: {}) {
                            Text("menu")
                        } }
                        .padding()
                    
                    // stats Grid
                    
                    LazyVGrid(columns: columns, spacing: 30){
                        ForEach(stats_Data){
                            stat in
                            VStack(spacing: 22){
                                HStack{
                                    Text(stat.title)
                                        .font(.system(size:22))
                                        .fontWeight(.bold)
                                    
                                    Spacer(minLength: 0)
                                }
                                
                                //Ring
                                
                                ZStack {
                                    Circle()
                                        .trim(from: 0, to:1)
                                        .stroke(stat.color.opacity(0.05), lineWidth: 10)
                                        .frame(width: (UIScreen.main.bounds.width - 150) / 2, height: (UIScreen.main.bounds.width - 150) / 2)
                                    
                                    Circle()
                                        .trim(from: 0, to:(stat.currentData / stat.goal))
                                        .stroke(stat.color.opacity(0.7), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                        .frame(width: (UIScreen.main.bounds.width - 150) / 2, height: (UIScreen.main.bounds.width - 150) / 2)
                                    
                                    Text(getPercent(current: stat.currentData, Goal: stat.goal) + " %")
                                        .font(.system(size: 22))
                                        .fontWeight(.bold)
                                        .foregroundColor(stat.color)
                                        .rotationEffect(.init(degrees: 90))
                                }
                                .rotationEffect(.init(degrees: -90))
                                
                            }
                            .padding()
                            .background(Color.black.opacity(0.06))
                            .cornerRadius(15)
                            .shadow(color : Color.black.opacity(0.1), radius: 1, x:0, y:0)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            
        }
        .navigationBarHidden(true)
        .tabItem{
            Text("ANALYZE")
            Image(systemName: "doc.text.below.ecg")
        }
    }
    
    //calculating type
    
    func getType(val: String) -> String{
        switch val {
        default: return "Kcal"
        }
    }
    //
    
    //func getDec(valu: CGFloat) -> String{
       // let format = NumberFormatter()
    //    format.numberStyle = .decimal
        
    //    return format.string(from: NSNumber.init(value: Float(val)))
    //}
    //calculating percent
    func getPercent(current : CGFloat, Goal : CGFloat) -> String{
        let per = (current / Goal) * 100
        
        return String(format: "%.1f", per)
    }
    
    func getHeight(value : CGFloat)->CGFloat{
        let col = CGFloat(value / 60) * 200
        
        return col
    }

    func getHrs(value: CGFloat)->String{
        let col = value
        
        return String(format:
            "%.1f", col)
    }
}

struct RoundedShape : Shape {
    func path(in rect: CGRect) -> Path{
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 5, height: 5))
        
        return Path(path.cgPath)
    }
}
// sample Data

struct Daily : Identifiable {
    
    var id : Int
    var day : String
    var Calorie : CGFloat
}

var workout_Data = [
    Daily(id: 0, day: "Sun", Calorie: 460),
    Daily(id: 1, day: "Mon", Calorie: 880),
    Daily(id: 2, day: "Tus", Calorie: 250),
    Daily(id: 3, day: "Wed", Calorie: 360),
    Daily(id: 4, day: "Thu", Calorie: 1220),
    Daily(id: 5, day: "Fri", Calorie: 750),
    Daily(id: 6, day: "Sat", Calorie: 950),
]
struct AnalyzeView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyzeView()
    }
}

// Stats Data

struct Stats : Identifiable {
    var id : Int
    var title : String
    var currentData : CGFloat
    var goal : CGFloat
    var color : Color
}

var stats_Data = [
    Stats(id: 0, title: "탄수화물", currentData: 70, goal: 100, color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))),
    Stats(id: 1, title: "단백질", currentData: 34, goal: 100, color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))),
    Stats(id: 2, title: "지방", currentData: 64, goal: 100, color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))),
    Stats(id: 3, title: "당류", currentData: 79, goal: 90, color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))),
    Stats(id: 4, title: "나트륨", currentData: 43, goal: 100, color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))),
    Stats(id: 5, title: "포화지방", currentData: 102, goal: 100, color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
]
