//
//  ContentView.swift
//  hitRocks
//
//  Created by Aryan Sefidi on 10/16/21.
//

import SwiftUI
import Charts

struct MultiLineChartView : UIViewRepresentable {
    
    var entries1 : [ChartDataEntry]
    var entries2 : [ChartDataEntry]
    var days: [String]
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        return createChart(chart: chart)
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = addData()
    }
    
    func createChart(chart: LineChartView) -> LineChartView{
        chart.chartDescription?.enabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawLabelsEnabled = true
        chart.xAxis.drawAxisLineEnabled = false
        chart.xAxis.labelPosition = .bottom
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.drawBordersEnabled = false
        chart.legend.form = .none
        chart.xAxis.labelCount = 7
        chart.xAxis.forceLabelsEnabled = true
        chart.xAxis.granularityEnabled = true
        chart.xAxis.granularity = 1
        chart.xAxis.valueFormatter = CustomChartFormatter(days: days)
        
        chart.data = addData()
        return chart
    }
    
    func addData() -> LineChartData{
        let data = LineChartData(dataSets: [
            //Schedule Trips Line
            generateLineChartDataSet(dataSetEntries: entries1, color: UIColor(Color(#colorLiteral(red: 0.6235294118, green: 0.7333333333, blue: 0.3568627451, alpha: 1))), fillColor: UIColor(Color(#colorLiteral(red: 0, green: 0.8134518862, blue: 0.9959517121, alpha: 1)))),
            //Unloadings Line
            generateLineChartDataSet(dataSetEntries: entries2, color: UIColor(Color(#colorLiteral(red: 0.003921568627, green: 0.231372549, blue: 0.431372549, alpha: 1))), fillColor: UIColor(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))))
        ])
        return data
    }
    
    func generateLineChartDataSet(dataSetEntries: [ChartDataEntry], color: UIColor, fillColor: UIColor) -> LineChartDataSet{
        let dataSet = LineChartDataSet(entries: dataSetEntries, label: "")
        dataSet.colors = [color]
        dataSet.mode = .cubicBezier
        dataSet.circleRadius = 5
        dataSet.circleHoleColor = UIColor(Color(#colorLiteral(red: 0.003921568627, green: 0.231372549, blue: 0.431372549, alpha: 1)))
        dataSet.fill = Fill.fillWithColor(fillColor)
        dataSet.drawFilledEnabled = true
        dataSet.setCircleColor(UIColor.clear)
        dataSet.lineWidth = 2
        dataSet.valueTextColor = color
        dataSet.valueFont = UIFont(name: "Avenir", size: 12)!
        return dataSet
    }
    
}

class CustomChartFormatter: NSObject, IAxisValueFormatter {
    var days: [String]
    
    init(days: [String]) {
        self.days = days
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return days[Int(value-1)]
    }
}


struct ContentView: View {

    let first_day = 7675 // the number of days since reference date that had passed when I first started (Nov 24, 2021)
    @State var values = [Int](repeating: 0, count: 10)
    @State var last_touched: [Int] = []
    @State private var showingAlert = false
    @State var date = Date()
    
    let defaults = UserDefaults.standard
    
    func start()
    {
        let days_passed = daysSinceStart()
        for idx in 0..<values.count
        {
            values[idx] = defaults.integer(forKey: days_passed + String(idx))
        }
    }
    
    func clearMemory()
    {
        let days_passed = daysSinceStart()

        for idx in 0..<values.count
        {
            defaults.set(0, forKey: days_passed + String(idx))
        }
        last_touched = []
        start()
    }
    
    func incrementCount(location: Int)
    {
        let days_passed = daysSinceStart()

        let cur = defaults.integer(forKey: days_passed + String(location)) + 1
        defaults.set(cur, forKey: days_passed + String(location))
        values[location] = cur
        last_touched.append(location)
    }
    
    func revert()
    {
        let days_passed = daysSinceStart()

        if let last = last_touched.popLast()
        {
            let cur = defaults.integer(forKey: days_passed + String(last)) - 1
            defaults.set(cur, forKey: days_passed + String(last))
            values[last] = cur
        }
    }
    
    func getCount(location: Int) -> String
    {
        String(defaults.integer(forKey: String(location)))
    }
    
    
    func smallButton(name: String, color_start: Color, color_end: Color, location: Int) -> some View
    {
        return AnyView(HStack{
            Text("\(values[location])").padding()
            
            Button(action: {
                incrementCount(location: location)
            }) {
                Text("\(name)")
                    .fontWeight(.semibold)
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 15)
                    .padding()
                    .foregroundColor(.black)
                    .background(LinearGradient(gradient: Gradient(colors: [color_start, color_end]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(40)
                    .frame(width: 300)
                    .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.black, lineWidth: 4))
            }
        })
    }
    
    func bigButton(name: String, color: Color, location: Int) -> some View
    {
        return AnyView(HStack{
            Text("\(values[location])").padding()
            
            Button(action: {
                incrementCount(location: location)
            }) {
                Text("\(name)")
                    .fontWeight(.semibold)
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.black)
                    .background(color)
                    .frame(maxWidth: .infinity )
                    .cornerRadius(40)
                    .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.black, lineWidth: 4))
            }
        })
    }
    

    
    func daysSinceStart() -> String
    {
        let beginning = Date(timeIntervalSinceReferenceDate: 0)
        let days = Calendar.current.dateComponents([.day], from: beginning, to: Date()).day ?? 0
        
        return String(days - first_day)
    }
    
    struct CountView: View {
        let first_day = 7675
        @State var total_sum = 0
        @State var days_since_start = 0
        let defaults = UserDefaults.standard
        @State var day_array = Array(repeating: Array(repeating: 0, count: 10), count: 1)
        
        func setDaysSinceStart()
        {
            let beginning = Date(timeIntervalSinceReferenceDate: 0)
            let days = Calendar.current.dateComponents([.day], from: beginning, to: Date()).day ?? 0
            
            days_since_start = days - first_day
        }

        func daysSinceStart() -> String
        {
            let beginning = Date(timeIntervalSinceReferenceDate: 0)
            let days = Calendar.current.dateComponents([.day], from: beginning, to: Date()).day ?? 0
            
            return String(days - first_day)
        }
        
        
        func createMatrix() -> [[Int]]
        {
            print("hit function")
            let days_since = Int(daysSinceStart()) ?? 0
            var array = Array(repeating: Array(repeating: 1, count: 10), count: days_since+1)
            var sum = 0
            var location = "0"

            
            for i in 0...days_since
            {
                for j in 0..<10
                {
                    location = String(i) + String(j)
                    array[i][j] = defaults.integer(forKey: String(location))
                    sum += array[i][j]
                }
            }
            
            day_array = array
            total_sum = sum
            return array
        }
        
        // always 10 rows since that's number of difficulties, columns keep growing with days
        var body: some View {
            let completed_array = createMatrix()
//
//            Text("Hi, you've completed: " + String(completed_array.joined().reduce(0, +)) + " routes.")
//
//            Text("Days since starting: " + daysSinceStart() + ".")
//
//            ForEach(completed_array, id: \.self) {
//                day in ForEach(day, id: \.self)
//                {
//                    climb in Text(String(climb))
//                }
//            }
//
//            Text("End Help")
//
            let days = ["S", "M", "T", "W", "T", "F", "S"]
            let entries1 = [
                ChartDataEntry(x: 1, y: 1),
                ChartDataEntry(x: 2, y: 2),
                ChartDataEntry(x: 3, y: 0),
                ChartDataEntry(x: 4, y: 0),
                ChartDataEntry(x: 5, y: 0),
                ChartDataEntry(x: 6, y: 0),
                ChartDataEntry(x: 7, y: 1),
                
            ]
            let entries2 = [
                ChartDataEntry(x: 1, y: 2),
                ChartDataEntry(x: 2, y: 3),
                ChartDataEntry(x: 3, y: 0),
                ChartDataEntry(x: 4, y: 0),
                ChartDataEntry(x: 5, y: 0),
                ChartDataEntry(x: 6, y: 0),
                ChartDataEntry(x: 7, y: 2)
            ]
            
            

            VStack{
                Spacer()
                MultiLineChartView(entries1: entries1, entries2: entries2, days: days)
                .frame(height: 220)
                Spacer()
            }
            

        }
        
    }
    
    var body: some View {
        NavigationView {

        VStack{
            HStack{
                Button(action: {
                    revert()
                }) {
                    Text("Undo")
                        .fontWeight(.semibold)
                        .font(.title)
                        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 15)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(40)
                        .frame(width: 200)
                        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.black, lineWidth: 4))
                }.onAppear(perform: self.start)
                
                
                if #available(iOS 15.0, *) {
                    Button(action:
                            {
                        showingAlert = true
                    }) {
                        Text("Clear Day")
                            .fontWeight(.semibold)
                            .font(.title)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 15)
                            .padding()
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(40)
                            .frame(width: 200)
                            .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.black, lineWidth: 4))
                    }
                    .alert("Are you sure you want to clear all of today's progress?", isPresented: $showingAlert) {
                        Button("Yes") { clearMemory() }
                        Button("No") { }
                    }
                } else {
                    // Fallback on earlier versions
                }

            }
            Group{
            self.smallButton(name: "V0/5.9", color_start: Color.white, color_end: Color.yellow, location: 0)
            
            self.bigButton(name: "V0-V1", color: Color.yellow, location: 1)
            
            
            self.smallButton(name: "V1/5.10+", color_start: Color.yellow, color_end: Color.green, location: 2)
            
            self.bigButton(name: "V1-V2", color: Color.green, location: 3)
            
            self.smallButton(name: "V2/5.11-", color_start: Color.green, color_end: Color.red, location: 4)

            self.bigButton(name: "V2-V3", color: Color.red, location: 5)
            
            self.smallButton(name: "V3/5.11+", color_start: Color.red, color_end: Color.blue, location: 6)
            
            self.bigButton(name: "V3-V4", color: Color.blue, location: 7)
            

            self.smallButton(name: "V4/5.12-", color_start: Color.blue, color_end: Color.orange, location: 8)
            
            self.bigButton(name: "V4-V5", color: Color.orange, location: 9)


            }
                    
            NavigationLink(destination: CountView()) {
                                Text("Go To Count")
            }.navigationBarTitle("", displayMode: .inline)
             .navigationBarHidden(false)
            
            }

            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
