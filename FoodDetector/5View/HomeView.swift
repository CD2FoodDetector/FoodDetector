//
//  HomeView.swift
//  FoodDetector
//
//  Created by 최유진 on 2021/12/03
//

import SwiftUI
import Combine

extension Color {
    static let lightgray = Color("lightgray")
}

struct UserDateInfo: Codable{
    var infoList: [[String: Int]]
    var infoNum: Int
    var user_calorie: Int
    var user_carbo: Int
    var user_fat: Int
    var user_protein: Int
}

// data declaration
var calorie = Legend(color: .red, label: "총 칼로리")
var carbon = Legend(color: .green, label: "탄수화물")
var protein = Legend(color: .blue, label: "단백질")
var fat = Legend(color: .orange, label: "지방")

// value = 섭취량 / 목표량
// DB에서 날짜에 맞게 정보 return 받도록 수정
var dataPoints: [DataPoint] = [
    DataPoint(value: 0.8, legend: calorie),
    DataPoint(value: 0.7, legend: carbon),
    DataPoint(value: 0.4, legend: protein),
    DataPoint(value: 0.5, legend: fat),
]

var barMaxWidth: CGFloat = 250

var curDate: Date = Date()

struct HomeView: View {
    private let calendar: Calendar
    private let monthDayFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    
    private static var now = Date()
    @State private var selectedDate = Self.now
    
    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthDayFormatter = DateFormatter(dateFormat: "MM월 dd일", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "E", calendar: calendar)
    }
    
    var body: some View {
        
        VStack {
            WeeklyCalendarView(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    Button(action: {
                        selectedDate = date
                        curDate = date
                    }) {
                        Text("00")
                            .font(.system(size: 6))
                            .padding(8)
                            .foregroundColor(.clear)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(dayFormatter.string(from: date))
                                    .foregroundColor(
                                        calendar.isDate(date, inSameDayAs: selectedDate) ?
                                            Color.black : .gray
                                    )
                                    .fontWeight(
                                        calendar.isDate(date, inSameDayAs: selectedDate) ?
                                            .bold
                                            : calendar.isDateInToday(date) ? .bold
                                            : .light
                                    )
                        )
                    }
                },
                header: { date in
                    Text(weekDayFormatter.string(from: date))
                        .font(.system(size: 18))
                        .fontWeight(
                            calendar.isDate(date, inSameDayAs: selectedDate) ?
                                .bold : .medium
                        )
                        .padding(.top, 5)
                },
                title: { date in
                    HStack {
                        Text(monthDayFormatter.string(from: selectedDate))
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                    }
                    .offset(x: 22, y: 0)
                    .frame(width: 100, height: 40, alignment: .center)
                },
                switcher: { date in
                    Button {
                        guard let newDate = calendar.date(
                                byAdding: .weekOfMonth,
                                value: -1,
                                to: selectedDate
                        ) else { return }
                        
                        selectedDate = newDate
                        curDate = newDate
                    } label: {
                        Label(
                            title: { Text ("Previous") },
                              icon: { Image(systemName: "chevron.left") }
                        )
                        .labelStyle(IconOnlyLabelStyle())
                        .foregroundColor(Color.black)
                    }
                    .offset(x: -120, y: 0)
                    Button {
                        guard let newDate = calendar.date(
                                byAdding: .weekOfMonth,
                                value: 1,
                                to: selectedDate
                        ) else { return }
                        
                        selectedDate = newDate
                        curDate = newDate
                    } label: {
                        Label(
                            title: { Text("Next") },
                            icon: { Image(systemName: "chevron.right") }
                        )
                        .labelStyle(IconOnlyLabelStyle())
                        .foregroundColor(Color.black)
                    }
                    .offset(x: 10, y: 0)
                }
            ).padding(.bottom, 10)
            DailyNutritionView(date: selectedDate)
            ImageScrollView(date: selectedDate)
        }
    }
}

public struct WeeklyCalendarView<Day: View, Header: View, Title: View, Switcher: View>: View {
    private var calendar: Calendar
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let header: (Date) -> Header
    private let title: (Date) -> Title
    private let switcher: (Date) -> Switcher
    
    private let daysInWeek = 7
    
    public init (
        calendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title,
        @ViewBuilder switcher: @escaping (Date) -> Switcher
    ) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.header = header
        self.title = title
        self.switcher = switcher
    }
    
    public var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()
        
        VStack {
            HStack {
                title(month)
                switcher(month)
            }
            HStack(spacing: 37) {
                ForEach(days.prefix(daysInWeek), id: \.self, content: header)
            }
            HStack(spacing: 28) {
                ForEach(days, id: \.self) { date in
                    content(date)
                }
            }
        }
    }
}

private extension WeeklyCalendarView {
    func makeDays() -> [Date] {
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: date),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: firstWeek.end - 1)
        else {
            return []
        }
        
        let dateInterval = DateInterval(start: firstWeek.start, end: lastWeek.end)
        
        return calendar.generateDays(for: dateInterval)
    }
}

private extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]
        
        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }
            
            guard date < dateInterval.end else {
                stop = true
                
                return
            }
            
            dates.append(date)
        }
        
        return dates
    }
    
    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start))
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
        self.locale = Locale(identifier: "ko_KR")
    }
}

public struct DailyNutritionView: View {
    
    @State var date: Date
    @State var total: [Double] = [0.0,0.0,0.0,0.0]
    @State var isModified = false
    private var max: Double {
        guard let max = dataPoints.max()?.endValue, max != 0 else {
            return 1
        }
        return max
    }
    
    public var body: some View {
        // Daily 영양분 섭취량
        VStack(spacing: 8) {
            ForEach(dataPoints, id: \.self) { bar in
                HStack{
                    Text(bar.legend.label)
//                        .fontWeight(.semibold)
                        .frame(width: 70, height: 20, alignment: .leading)
                    
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .foregroundColor(.lightgray)
                        .frame(width: CGFloat(barMaxWidth), height: 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(bar.legend.color)
                                .frame(width: CGFloat(bar.endValue) * barMaxWidth),
                            alignment: .leading
                    )
                }
            }
        }
        /*
        .onAppear(perform: {
            get_user_info("user0001", date)
            dataPoints[0] = DataPoint(value: total[0]/1700, legend: calorie)
            dataPoints[1] = DataPoint(value: total[1]/100, legend: carbon)
            dataPoints[2] = DataPoint(value: total[2]/50, legend: protein)
            dataPoints[3] = DataPoint(value: total[3]/40, legend: fat)
        })
        */
        .onReceive(Just(isModified), perform: { d in
            
            if date != curDate{
                date = curDate
                isModified = false
            }
            if !isModified{
                get_user_info("user0001", curDate)
            }
            
            dataPoints[0] = DataPoint(value: total[0]/2000, legend: calorie)
            dataPoints[1] = DataPoint(value: total[1]/140, legend: carbon)
            dataPoints[2] = DataPoint(value: total[2]/50, legend: protein)
            dataPoints[3] = DataPoint(value: total[3]/50, legend: fat)
        })
         
    }
    
    func get_user_info(_ id: String, _ date: Date) {
        guard let url = URL(string: "http://3.36.103.81:80/account/user_date_info") else {
            print("Invalid url")
            return
        }
        print("get_user_info called. date is \(date) \(isModified)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["id":id, "date": dateFormatter.string(from: date)], options: [])

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let result = try! JSONDecoder().decode(UserDateInfo.self, from: data!)
            total = [0.0, 0.0, 0.0, 0.0]
            for r in result.infoList {
                print("r is  \(r)")
                total[0] += Double(r["calories_total"] ?? 0)
                total[1] += Double(r["carbo_total"] ?? 0)
                total[2] += Double(r["fat_total"] ?? 0)
                total[3] += Double(r["protein_total"] ?? 0)
            }
            
            dataPoints[0] = DataPoint(value: total[0]/2000, legend: calorie)
            dataPoints[1] = DataPoint(value: total[1]/140, legend: carbon)
            dataPoints[2] = DataPoint(value: total[2]/50, legend: protein)
            dataPoints[3] = DataPoint(value: total[3]/50, legend: fat)
            isModified = true
        }.resume()
    }
}

struct ImageScrollView: View {
    @State var imgList: [String] = []
    @State var date: Date
    @EnvironmentObject var cv: CommonVar
    
    @State var mealList = ["아침", "점심", "저녁"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content:
                    {
                        VStack(spacing: 0){
                            ForEach(Array(zip(imgList, mealList)), id: \.0) { item in
                                ZStack{
                                    VStack(spacing: 10){
                                        Text(item.1)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                        Image(uiImage: load_img(item.0))
                                            .resizable()
                                            .cornerRadius(5.0)
                                            .frame(width: 330, height: 220)
                                    }
                                }
                                .padding(10)
                                .background(Color.black.opacity(0.06))
                                .cornerRadius(10)
                                .padding(10)
                            }
                        }
                    }
        )
        .onAppear(perform: {
            get_imgs_list("user0001", date)
        })
        .onReceive(Just(date), perform: { d in
            //print("d is \(d), and date is \(date)")
            //print("And!!!  curDate is \(curDate)")
            //date = curDate
            get_imgs_list("user0001", curDate)
        })
    }
    
    func get_imgs_list(_ id: String, _ date: Date) {
        guard let url = URL(string: "http://3.36.103.81:80/account/profile_meal") else {
            print("Invalid url")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["id":id, "token": cv.token, "date": dateFormatter.string(from: date)], options: [])
        print("in Home. token = \(cv.token)")
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(calendar: Calendar(identifier: .gregorian))
    }
}
