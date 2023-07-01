//
//  ContentView.swift
//  ReactionTime
//
//  Created by Thomas Povinelli on 6/30/23.
//

import SwiftUI

class ELTimer: ObservableObject {
    var triggerTime: Date? = nil
    @Published var timer: Timer? = nil
}

struct Result: Equatable, Hashable, Identifiable, CustomStringConvertible {
    var elapsed: Int
    var date: Date
    
    public var description: String {
        "\(date): \(elapsed)ms"
    }
    
    
    public var id: Date { date }
}

struct ContentView: View {
    @State var backgroundColor: Color = .red
    @State var statusText = "Click to start"
    @State var canRelease = false
    
    @State var times: [Result] = []
    
    @StateObject var timer: ELTimer = ELTimer()
    
    var body: some View {
        TabView {
            GeometryReader { geometry in
                VStack() {
                    ZStack {
                        Text(statusText).font(.title).foregroundColor(.white)
                        Rectangle().frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height).foregroundColor(.clear).contentShape(Rectangle())
                        
                            .gesture(DragGesture(minimumDistance: 0).onChanged({_ in
                                timer.timer?.invalidate()
                                statusText = "HOLD..."
                                backgroundColor = .red
                                
                                canRelease = false
                                let date = Date.now.advanced(by: TimeInterval(floatLiteral: Double.random(in: 0.5...2.5)))
                                timer.triggerTime = date
                                timer.timer = Timer(fire: date, interval: 1, repeats: false, block: {_ in
                                   canRelease = true
                                    backgroundColor = .green
                                    statusText = "RELEASE!"

                                })
                                RunLoop.main.add(timer.timer!, forMode: .common)
                            }).onEnded({_ in
                                timer.timer?.invalidate()
                                statusText = times.last?.elapsed.description ?? "ERROR"
                                
                                if canRelease {
                                    let elapsed = Int((Date.now.timeIntervalSince(timer.triggerTime!) * 1000).rounded())
                                    statusText = "Time: \(elapsed)ms"
                                    backgroundColor = .green
                                    times.append(Result(elapsed: elapsed, date: Date.now))
                                } else {
                                    backgroundColor = .blue
                                    statusText = "Too Soon!"
                                }
                                
                                canRelease = false
                            }))
                    }
                }
                .background(backgroundColor)
                
            }.tabItem({
                Image(systemName: "hand.tap")
                Text("Play")
            })
            VStack {
                Text("List of reaction times (ms)").font(.headline)
                List(times, rowContent: { id in
                    Text("\(id.description)")
                })
                Text("Average reaction time: \(averageTime)ms")
            }.tabItem({
                Image(systemName: "list.bullet")
                Text("Scores")
            })
        }.padding()
        #if os(iOS)
            .onAppear{
                let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithDefaultBackground()
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        #endif
    }
    
    var averageTime: Int {
        let sum = times.map { $0.elapsed }.reduce(0, +)
        return (sum) / (times.count)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
