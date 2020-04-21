//
//  ContentView.swift
//  WordScramble
//
//  Created by Lance Kent Briones on 4/19/20.
//  Copyright © 2020 Lance Kent Briones. All rights reserved.
//

import SwiftUI
struct PointStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .foregroundColor(.black)
            .lineSpacing(50)
            .shadow(color: .blue, radius: 1)
            //.padding()
    }
}
extension View {
    func point_design() -> some View {
        self.modifier(PointStyle())
    }
}
struct ContentView: View {
    @State private var all_words = [String]()
    
    @State private var used_words = [String]()
    @State private var root_word: String = ""
    @State private var new_word: String = ""
    
    @State private var error_title: String = ""
    @State private var error_message: String = ""
    @State private var show_alert: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter word", text: $new_word){
                    self.add_word()
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
                
                List(self.used_words, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                .listStyle(GroupedListStyle())
                
                Text("Your point is: \(self.used_words.count)")
                    .fontWeight(.black)
                    .point_design()
            }
            .navigationBarTitle(Text(self.root_word), displayMode: .large)
            .navigationBarItems(trailing:
                Button(action: {
                    self.reset()
                }){
                    HStack{
                        Image(systemName: "repeat")
                        Text("Reset")
                    }
                }
            )
            .onAppear(perform: {
                self.start_game()
            })
            .alert(isPresented: $show_alert){
                Alert(title: Text(self.error_title), message: Text(self.error_message), dismissButton: .default(Text("Continue")))
            }
        }
    }
    func reset() -> Void {
        self.root_word = self.all_words.randomElement() ?? "cocacola"
        self.new_word = ""
        self.used_words.removeAll()
    }
    func error_modifier(title: String, message: String) -> Void {
        self.error_title = title
        self.error_message = message
        self.show_alert = true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound       // will return true if it's an english word
    }
    func isOriginal(word: String) -> Bool {
        return !self.used_words.contains(word)
    }
    func isShort(word: String) -> Bool{
        return self.new_word.count < 3
    }
    func isSame(word: String) -> Bool{
        return word == self.root_word
    }
    func isPossible(word: String) -> Bool {
        var tempWord = self.root_word.lowercased()
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }
            else{
                return false
            }
        }
        return true
    }
    func add_word() -> Void {
        let answer = self.new_word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !self.isShort(word: answer) else {
            self.error_modifier(title: "Too short!", message: "Word must contain at least 3 letters")
            
            return
        }
        guard self.isOriginal(word: answer) else {
            self.error_modifier(title: "Unoriginal!", message: "You've already entered \(self.new_word), please enter a unique one.")
            
            return
        }
        guard self.isReal(word: answer) else {
            self.error_modifier(title: "Not a real word!", message: "Please use a real world that can be found in the English dictionary.")
            
            return
        }
        guard self.isPossible(word: answer) else {
            self.error_modifier(title: "Not in the rootword!", message: "\(self.new_word) is not contained in \(self.root_word) by any means.")
            
            return
        }
        guard !self.isSame(word: answer) else {
            self.error_modifier(title: "Entering \(self.root_word) isn't allowed!", message: "You must give out a new word aside from the one given to you")
            
            return
        }
        
        self.used_words.insert(answer, at: 0)
        self.new_word = ""
    }
    func start_game() -> Void {
        if let startURL = Bundle.main.url(forResource: "start", withExtension: ".txt"){
            if let load = try? String(contentsOf: startURL){
                // all constraints are sucessfully followed
                
                // load now becomes an array
                self.all_words = load.components(separatedBy: .newlines)
                
                
                self.root_word = all_words.randomElement() ?? "warriors"
                
                return
            }
        }
        
        fatalError("Could not load start.txt from the bundle!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
