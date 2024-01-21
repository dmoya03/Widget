//
//  MyWidget.swift
//  MyWidget
//
//  Created by Daniel Moya on 17/1/24.
//

import WidgetKit
import SwiftUI

//MODELO VAR
struct Model: TimelineEntry {
    var date: Date
    var widgetData: [JsonData]
}

struct JsonData: Decodable {
    var id: Int
    var name: String
    var email: String
}

//PROVIDER
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Model {
        return Model(date: Date(), widgetData: Array(repeating: JsonData(id: 1, name: "", email: ""), count: 2))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Model) -> Void) {
        completion(Model(date: Date(), widgetData: Array(repeating: JsonData(id: 1, name: "", email: ""), count: 2)))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Model>) -> Void) {
        getJson { (modelData) in
            let data = Model(date: Date(), widgetData: modelData)
            guard let update = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) else { return }
            let timeline = Timeline(entries: [data], policy: .after(update))
            completion(timeline)
        }
    }
    
    typealias Entry = Model
}

func getJson(completion: @escaping ([JsonData]) -> ()){
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/comments?postId=1") else { return }
    
    URLSession.shared.dataTask(with: url){data,_,_ in
        guard let data = data else{ return }
        do{
            let json = try JSONDecoder().decode([JsonData].self, from: data)
            DispatchQueue.main.async {
                completion(json)
            }
        } catch let error as NSError {
            print("Fail", error.localizedDescription)
        }
    }.resume()
}

//DISENO - VISTA
struct view: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .center){
                Text("My List")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                Text(String(entry.widgetData.count)).font(.custom("Arial", size: 80)).bold()
                Spacer()
            }
        case .systemMedium:
            VStack(alignment: .center){
                Text("My List")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                VStack(alignment: .leading){
                    //Item 1
                    Text(entry.widgetData[0].name).bold()
                    Text(entry.widgetData[0].email)
                    //Item 2
                    Text(entry.widgetData[1].name).bold()
                    Text(entry.widgetData[1].email)
                }.padding(.leading)
                Spacer()
            }
        default:
            VStack(alignment: .center){
                Text("My List")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                VStack(alignment: .leading){
                    ForEach(entry.widgetData, id: \.id){ item in
                        Text(item.name).bold()
                        Text(item.email)
                    }
                }.padding(.leading)
                Spacer()
            }
        }
    }
    
    
}

//CONFIGURACION
@main
struct MyWidget: Widget {
    
    var body: some WidgetConfiguration{
        StaticConfiguration(kind: "widget", provider: Provider()) { entry in
            view(entry: entry)
        }.description("Descripcion del widget")
            .configurationDisplayName("Nombre del widget")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
    
}

