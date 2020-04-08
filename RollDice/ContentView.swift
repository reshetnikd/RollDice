//
//  ContentView.swift
//  RollDice
//
//  Created by Dmitry Reshetnik on 08.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    @State private var selection = 0
    @State private var diceRolls = [String]()
    @State private var randomIndex = 0
    @State private var engine: CHHapticEngine?
    
    let diceNumbers = ["⚀", "⚁", "⚂", "⚃", "⚄", "⚅"]
 
    var body: some View {
        TabView(selection: $selection){
            Button(action: {
                self.randomIndex = Int.random(in: 0...self.diceNumbers.count - 1)
                self.roll()
                self.simpleSuccess()
            }) {
                Text(diceNumbers[randomIndex])
                    .font(.system(size: 164))
                    .foregroundColor(Color.black)
            }
            .tabItem {
                VStack {
                    Image("first")
                    Text("Throw")
                }
            }
            .tag(0)
            List {
                ForEach(diceRolls, id: \.self) { item in
                    Text(item)
                }
            }
            .tabItem {
                VStack {
                    Image("second")
                    Text("History")
                }
            }
            .tag(1)
        }
        .onAppear(perform: {
            self.loadData()
            self.roll()
            self.prepareHaptics()
        })
    }
    
    func roll() {
        diceRolls.append("\(diceNumbers[randomIndex]) rolled \(randomIndex + 1)")
        saveData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Rolls") {
            if let decoded = try? JSONDecoder().decode([String].self, from: data) {
                self.diceRolls = decoded
            }
        }
    }
    
    func saveData() {
        if let data = try? JSONEncoder().encode(diceRolls) {
            UserDefaults.standard.set(data, forKey: "Rolls")
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription).")
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
