//x
//  ContentView.swift
//  Jazz Training
//
//  Created by Manuel Kümpel on 01.09.21.
//

import SwiftUI
import CoreData

enum ChordsSum {
    case one, two, random
    
    func getAsInteger() -> Int { 
        switch self {
            case .one:
                return 1
            case .two:
                return 2
            case .random:
                return 3
        }
    }
        
    mutating func setFromInteger(_ num: Int) {
        switch num {
            case 1:
                self = .one
            case 2:
                self = .two
            case 3:
                self = .random
            default:
                self = .one
        }
    }
}

enum RowCount {
    case one, double
    
    func getAsInteger() -> Int {
        switch self {
            case .one:
                return 1
            case .double:
                return 2
        }
    }
        
    mutating func setFromInteger(_ num: Int) {
        switch num {
            case 1:
                self = .one
            case 2:
                self = .double
            default:
                self = .one
        }
    }
}

enum LearnMode {
    case none, randomNotes, randomNumber, twoRandomNotes
    
    func getAsInteger() -> Int {
        switch self {
            case .none:
                return 1
            case .randomNotes:
                return 2
            case .randomNumber:
                return 3
            case .twoRandomNotes:
                return 4
        }
    }
        
    mutating func setFromInteger(_ num: Int) {
        switch num {
            case 1:
                self = .none
            case 2:
                self = .randomNotes
            case 3:
                self = .randomNumber
            case 4:
                self = .twoRandomNotes
            default:
            self = .none
        }
    }
}

struct ContentView: View {
    @State private var settings = SettingsData()
    @State private var showSheet = false
    
    @State private var chordsStringsState = [String]()
    @State private var chordsStringsState2 = [String]()
    
    @State private var chordsDegreeState = [String]()
    @State private var chordsDegreeState2 = [String]()

    @State private var whichScaleStates: ([Int], [Int]) = ([], [])
    
    @State private var allChords = [String]()
    @State private var selectedChords = ""
    @State private var useDegree = false

    @State private var chords: ([String], [String], [Int]) = ([], [], [])
    
    @State private var hasToChordsArray = [(String, Int)]()
    @State private var hasToChords: String = ""

    @State private var learnRange = 0
    
    @State private var allRanNum = [Int]()
    
    var body: some View {
        VStack(spacing: 0) {
            if useDegree {
                whichModeView
            }
            chordsView
            if settings.learnMode == .randomNotes {
                extraPracticView
                    .padding(.bottom, 5)
            } else if settings.learnMode == .randomNumber {
                randomNumView1
                    .padding(.bottom, 5)
            } else if settings.learnMode == .twoRandomNotes {
                twoRandomNotesView
                    .padding(.bottom, 5)
            }
            if settings.rowCount == .double {
                if useDegree {
                    whichModeView2
                }
                chordsView2
                    .onTapGesture {
                        hasToChordsArray = hasToChordGen()
                        chords = chordGen()
                        
                        let chordState = reChordsState()
                        chordsStringsState = chordState.0
                        chordsDegreeState = chordState.1
                        chordsStringsState2 = chordState.2
                        chordsDegreeState2 = chordState.3
                        whichScaleStates.0 = chordState.4
                        whichScaleStates.1 = chordState.5

                        useDegree = UserDefaults.standard.bool(forKey: "useDegree")
                        
                        allRanNum = createNewRanNum()
                    }
                if settings.learnMode == .randomNotes {
                    extraPracticView2
                } else if settings.learnMode == .randomNumber {
                    randomNumView2
                } else if settings.learnMode == .twoRandomNotes {
                    twoRandomNotesView
                        .padding(.bottom, 5)
                }
                
            }
            Button(action: {
                hasToChordsArray = hasToChordGen()
                chords = chordGen()
                
                let chordState = reChordsState()
                chordsStringsState = chordState.0
                chordsDegreeState = chordState.1
                chordsStringsState2 = chordState.2
                chordsDegreeState2 = chordState.3
                whichScaleStates.0 = chordState.4
                whichScaleStates.1 = chordState.5

                useDegree = UserDefaults.standard.bool(forKey: "useDegree")
                
                allRanNum = createNewRanNum()
            }, label: {
                Text("Next")
                    .font(.system(size: 25))
                    .padding(.top, 40)
            })
            
            Button(action: {
                allRanNum = createNewRanNum()
            }, label: {
                Text("Change Learn Letter")
                    .font(.system(size: 25))
            })
            Spacer()
        }
        .onTapGesture {
            showSheet = true
        }
        .sheet(isPresented: $showSheet, content: { Settings(selectedChords: $selectedChords,
            hasTochords: $hasToChords, settings: $settings, learnRange: $learnRange) })
        .onAppear {
            settings.chordsSum.setFromInteger(UserDefaults.standard.integer(forKey: "chordSum"))
            settings.rowCount.setFromInteger(UserDefaults.standard.integer(forKey: "rowCount"))
            settings.useDegree = UserDefaults.standard.bool(forKey: "useDegree")
            settings.hasToEveryLine = UserDefaults.standard.bool(forKey: "hasToEveryLine")
            settings.learnMode.setFromInteger(UserDefaults.standard.integer(forKey: "learnMode"))
            
            allChords = allChordGen()
            useDegree = UserDefaults.standard.bool(forKey: "useDegree")
            selectedChords = UserDefaults.standard.string(forKey: "selectedChords") ?? ""
            hasToChords = UserDefaults.standard.string(forKey: "hasToChords") ?? ""
            learnRange = UserDefaults.standard.integer(forKey: "learnRange")

            hasToChordsArray = hasToChordGen()
            
            chords = chordGen()
            let chordState = reChordsState()
            chordsStringsState = chordState.0
            chordsDegreeState = chordState.1
            chordsStringsState2 = chordState.2
            chordsDegreeState2 = chordState.3
            whichScaleStates.0 = chordState.4
            whichScaleStates.1 = chordState.5
            
            allRanNum = createNewRanNum()
            
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onChange(of: selectedChords, perform: { newValue in
            UserDefaults.standard.set(newValue, forKey: "selectedChords")
        })
        .onChange(of: hasToChords, perform: { newValue in
            UserDefaults.standard.set(newValue, forKey: "hasToChords")
        })
        .onChange(of: hasToChords, perform: { newValue in
            UserDefaults.standard.set(newValue, forKey: "hasToChords")
        })
        .onChange(of: learnRange, perform: { newValue in
            print("Test2")
            UserDefaults.standard.set(newValue, forKey: "learnRange")
        })
    }
    
    var twoRandomNotesView: some View {
        HStack(spacing: 0) {
            if chordsDegreeState.count > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text(genRandomNoteOfScale(count, false) + "-" + genRandomNoteOfScale(count, false))
                            .font(.system(size: 20))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(Color.orange)
                        
                        if settings.chordsSum == .two || settings.chordsSum == .random {
                            Text(genRandomNoteOfScale(count + 4, false) + "-" + genRandomNoteOfScale(count + 4, false))
                                .font(.system(size: 20))
                            .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .offset(x: PercSize.width(10))
                        }
                    }
                }
            }
        }
    }
    
    var twoRandomNotesView2: some View {
        HStack(spacing: 0) {
            if chordsDegreeState.count > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text(genRandomNoteOfScale(count, true) + "-" + genRandomNoteOfScale(count, true))
                            .font(.system(size: 20))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(Color.orange)
                        
                        if settings.chordsSum == .two || settings.chordsSum == .random {
                            Text(genRandomNoteOfScale(count + 4, true) + "-" + genRandomNoteOfScale(count + 4, true))
                                .font(.system(size: 20))
                            .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .offset(x: PercSize.width(10))
                        }
                    }
                }
            }
        }
    }
    
    var randomNumView1: some View {
        HStack(spacing: 0) {
            if chordsDegreeState.count > 0 && learnRange > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text("\(allRanNum[count])")
                            .font(.system(size: 20))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(Color.orange)
                    }
                }
            }
        }
    }
    
    var randomNumView2: some View {
        HStack(spacing: 0) {
            if chordsDegreeState.count > 0 && learnRange > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text("\(allRanNum[count + 4])")
                            .font(.system(size: 20))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(Color.orange)
                    }
                }
            }
        }
    }
    
    var extraPracticView: some View {
        HStack(spacing: 0) {
            if chordsDegreeState.count > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text(genRandomNoteOfScale(count, false))
                            .font(.system(size: 20))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(Color.orange)
                        
                        if settings.chordsSum == .two || settings.chordsSum == .random {
                            Text(genRandomNoteOfScale(count + 4, false))
                                .font(.system(size: 20))
                            .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .offset(x: PercSize.width(10))
                        }
                    }
                }
            }
        }
    }
    
    var extraPracticView2: some View {
        HStack(spacing: 0) {
            if chordsDegreeState.count > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text(genRandomNoteOfScale(count, true))
                            .font(.system(size: 20))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(Color.orange)
                        
                        if settings.chordsSum == .two || settings.chordsSum == .random {
                            Text(genRandomNoteOfScale(count + 4, true))
                                .font(.system(size: 20))
                            .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .offset(x: PercSize.width(10))
                        }
                    }
                }
            }
        }
    }
    
    func createNewRanNum() -> [Int] {
        var reArray = [Int]()
        for _ in 0..<8 {
            reArray.append(Int.random(in: 1...learnRange))
        }
        return reArray
    }
    
    func genRandomNoteOfScale(_ scaleRefernce: Int, _ secondLine: Bool) -> String {
        if whichScaleStates.0[scaleRefernce] == -1 && !secondLine {
            return ""
        }
        if whichScaleStates.1[scaleRefernce] == -1 && secondLine {
            return ""
        }
        
        var scale = whichScaleStates.0[scaleRefernce]
        if secondLine {
            scale = whichScaleStates.1[scaleRefernce]
        }

        var length = 7
        if scale > 12 && scale < 15 { length = 8 }
        if scale > 15 && scale < 17 { length = 6 }
        if scale > 16 { length = 7 }
        
        let randomInt = Int.random(in: 0...length)
        return cutOffToNote(getFromAllChord(whichScale: scale, whichChord: randomInt))
    }
    
    func cutOffToNote(_ chord: String) -> String {
        var returnString = ""
        for letterChord in chord {
            switch letterChord {
            case "-":
                continue
            case "+":
                continue
            case "△":
                continue
            case "ø":
                continue
            case "o":
                continue
            case "a":
                continue
            case "l":
                continue
            case "t":
                continue
            case "6":
                continue
            case "7":
                continue
            default:
                returnString.append(letterChord)
            }
        }
        return returnString
    }
    
    var chordsView: some View {
        HStack(spacing: 0) {
            if chordsStringsState.count > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text(chordsStringsState[count])
                            .font(.system(size: 30))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(15), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(twoOranges(count: count))
                        
                        if settings.chordsSum == .two || settings.chordsSum == .random {
                            Text(chordsStringsState[count + 4])
                                .font(.system(size: 30))
                            .frame(width: PercSize.width(20), height: PercSize.heigth(15), alignment: .bottomLeading)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .offset(x: PercSize.width(10))
                        }
                    }
                }
            }
        }
    }
    
    var chordsView2: some View {
        HStack(spacing: 0) {
            if chordsStringsState2.count > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text(chordsStringsState2[count])
                            .font(.system(size: 30))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(15), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(twoOranges(count: count, true))
                        
                        if settings.chordsSum == .two || settings.chordsSum == .random {
                            Text(chordsStringsState2[count + 4])
                                .font(.system(size: 30))
                            .frame(width: PercSize.width(20), height: PercSize.heigth(15), alignment: .bottomLeading)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .offset(x: PercSize.width(10))
                        }
                    }
                }
            }
        }
    }
    
    var whichModeView: some View {
        HStack(spacing: 0) {
            if chordsDegreeState.count > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text(chordsDegreeState[count])
                            .font(.system(size: 20))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(Color.green)
                        
                        if settings.chordsSum == .two || settings.chordsSum == .random {
                            Text(chordsDegreeState[count + 4])
                                .font(.system(size: 20))
                            .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .offset(x: PercSize.width(10))
                        }
                    }
                }
            }
        }
    }
    
    var whichModeView2: some View {
        HStack(spacing: 0) {
            if chordsDegreeState2.count > 0 {
                ForEach(0..<4) { count in
                    ZStack {
                        Text(chordsDegreeState2[count])
                            .font(.system(size: 20))
                        .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(Color.green)
                        
                        if settings.chordsSum == .two || settings.chordsSum == .random {
                            Text(chordsDegreeState2[count + 4])
                                .font(.system(size: 20))
                            .frame(width: PercSize.width(20), height: PercSize.heigth(6), alignment: .bottomLeading)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .offset(x: PercSize.width(10))
                        }
                    }
                }
            }
        }
    }
    
    func hasToChordGen() -> [(String, Int)] {
        var reHasToChords: [(String, Int)] = []
        
        var currentIsScaleCount = false
        var currentIsChordCount = false

        var scaleCount = ""
        var chordCount = ""
        
        for selectedLetter in hasToChords {
            if selectedLetter == ")" {
                reHasToChords.append((getFromAllChord(whichScale: (Int(String(scaleCount)) ?? 0) - 1,
                                                      whichChord: (Int(String(chordCount)) ?? 0) - 1),
                                     (Int(String(scaleCount)) ?? 0) - 1))

                scaleCount = ""
                chordCount = ""
                continue
            }
            if !currentIsScaleCount && selectedLetter == "(" {
                currentIsScaleCount = true
                currentIsChordCount = false
                continue
            }
            if currentIsScaleCount && selectedLetter == "/" {
                currentIsScaleCount = false
                currentIsChordCount = true
                continue
            }
            
            if currentIsChordCount {
                chordCount += String(selectedLetter)
            } else if currentIsScaleCount {
                scaleCount += String(selectedLetter)
            }
        }
        
        return reHasToChords
    }
    
    func chordGen() -> ([String], [String], [Int]) {
        var reChords: ([String], [String], [Int]) = ([], [], [])
        
        if selectedChords.count > 0 && selectedChords[
                selectedChords.index(selectedChords.startIndex, offsetBy: 0)] == "a" {
            
            for whichScale in 0..<allChords.count {
                var length = 7
                if whichScale > 11 && whichScale < 15 { length = 8 }
                if whichScale > 15 && whichScale < 17 { length = 6 }
                if whichScale > 16 { length = 4 }
                
                for count in 0..<length {
                    reChords.0.append(getFromAllChord(whichScale: whichScale, whichChord: count))
                    reChords.1.append(getDegree(whichScale: whichScale, whichChord: count))
                    reChords.2.append(whichScale)
                }
            }
            return reChords
        }
        
        if selectedChords.count > 0 && selectedChords[
                selectedChords.index(selectedChords.startIndex, offsetBy: 0)] == "x" {

            for whichScale in 0..<allChords.count {
                var whichChord = 0
                if whichScale < 12 {
                    whichChord = 4
                }

                reChords.0.append(getFromAllChord(whichScale: whichScale, whichChord: whichChord))
                reChords.1.append(getDegree(whichScale: whichScale, whichChord: whichChord))
                reChords.2.append(whichScale)
            }
            return reChords
        }
        
        var scaleCount = 0
        for selectedLetter in selectedChords {
            if selectedLetter == ")" {
                scaleCount += 1
                continue
            } else if selectedLetter == "(" {
                continue
            } else if selectedLetter == "," {
                continue
            }
            
            if (Int(String(selectedLetter)) ?? 0) == 9 {
                var length = 7
                if scaleCount > 11 && scaleCount < 15 { length = 8 }
                if scaleCount > 15 && scaleCount < 17 { length = 6 }
                if scaleCount > 16 { length = 4 }
                
                for allNum in 0..<length {
                    reChords.0.append(getFromAllChord(whichScale: scaleCount,
                                                    whichChord: allNum)
                    )
                    reChords.1.append(getDegree(whichScale: scaleCount,
                                                whichChord: allNum)
                    )
                    reChords.2.append(scaleCount)
                    
                }
                continue
            }
            if selectedLetter == "0" {
                continue
            }
            reChords.0.append(getFromAllChord(whichScale: scaleCount,
                                            whichChord: (Int(String(selectedLetter)) ?? 0) - 1)
            )
            reChords.1.append(getDegree(whichScale: scaleCount,
                                        whichChord: (Int(String(selectedLetter)) ?? 0) - 1)
            )
            reChords.2.append(scaleCount)
            
        }
        return reChords
    }
    
//    func getDegree(whichScale: Int, whichChord: Int) -> String {
//        if whichScale < 12 {
//            return String(whichChord + 1)
//        } else if whichScale > 16 {
//            switch whichChord {
//                case 0, 3:
//                    return "MM1"
//                case 1:
//                    return "MM6"
//                case 2:
//                    return "Alt"
//                default:
//                    break
//            }
//        } else if whichScale == 15 {
//            return "1"
//        } else if whichScale == 16 {
//            return "2"
//        } else if whichScale > 11 && whichScale < 15 {
//            switch whichScale {
//                case 12:
//                    return "1"
//                case 13:
//                    return "2"
//                case 14:
//                    return "3"
//                default:
//                    break
//            }
//        }
//        return " "
//    }
    
    func getDegree(whichScale: Int, whichChord: Int) -> String {
        var addString = ""
        
        switch whichScale {
            case 0:
                addString = "C Dur"
            case 1:
                addString = "D♭ Dur"
            case 2:
                addString = "D Dur"
            case 3:
                addString = "E♭ Dur"
            case 4:
                addString = "E Dur"
            case 5:
                addString = "F Dur"
            case 6:
                addString = "G♭ Dur"
            case 7:
                addString = "G Dur"
            case 8:
                addString = "A♭ Dur"
            case 9:
                addString = "A Dur"
            case 10:
                addString = "B♭ Dur"
            case 11:
                addString = "B Dur"
            
            case 17:
                addString = "C MM"
            case 18:
                addString = "D♭ MM"
            case 19:
                addString = "D MM"
            case 20:
                addString = "E♭ MM"
            case 21:
                addString = "E MM"
            case 22:
                addString = "F MM"
            case 23:
                addString = "G♭ MM"
            case 24:
                addString = "G MM"
            case 25:
                addString = "A♭ MM"
            case 26:
                addString = "A MM"
            case 27:
                addString = "B♭ MM"
            case 28:
                addString = "B MM"
        
            default:
                break
        }
        
        if whichScale < 12 {
            return addString
        } else if whichScale > 16 {
            return addString
        } else if whichScale == 15 {
            return "1"
        } else if whichScale == 16 {
            return "2"
        } else if whichScale > 11 && whichScale < 15 {
            switch whichScale {
                case 12:
                    return "1"
                case 13:
                    return "2"
                case 14:
                    return "3"
                default:
                    break
            }
        }
//        if whichScale < 12 {
//            return String(whichChord + 1) + addString
//        } else if whichScale > 16 {
//            switch whichChord {
//                case 0:
//                    return "MM1" + addString
//                case 1:
//                    return "MM6" + addString
//                case 2:
//                    return "Alt" + addString
//                default:
//                    break
//            }
//        } else if whichScale == 15 {
//            return "1"
//        } else if whichScale == 16 {
//            return "2"
//        } else if whichScale > 11 && whichScale < 15 {
//            switch whichScale {
//                case 12:
//                    return "1"
//                case 13:
//                    return "2"
//                case 14:
//                    return "3"
//                default:
//                    break
//            }
//        }
        return " "
    }
    func reYesNo() -> Bool {
        let randomInt = Int.random(in: 0..<2)
        if randomInt == 0 {
            return false
        }
        return true
    }
    
    func twoOranges(count: Int, _ different: Bool = false) -> Color {
        if different {
            if count % 2 != 0 {
                return Color.init(red: 230 / 255, green: 130 / 255, blue: 69 / 255)
            } else {
                return Color.init(red: 138 / 255, green: 65 / 255, blue: 21 / 255)
            }
        }
        if count % 2 == 0 {
            return Color.init(red: 230 / 255, green: 130 / 255, blue: 69 / 255)
        } else {
            return Color.init(red: 138 / 255, green: 65 / 255, blue: 21 / 255)
        }
    }
    
    func reChordsState() -> ([String], [String], [String], [String], [Int], [Int])  {
        var reStrings: ([String], [String], [String], [String], [Int], [Int]) = ([], [], [], [], [], [])
        
        enum ComesLine {
            case first, second, none, both
        }
        
        var hastToInFirstLine = reYesNo()
        var comesFromLine: ComesLine = .none

        if settings.rowCount == .one {
            hastToInFirstLine = true
        }
        
        while true {
            reStrings = ([], [], [], [], [], [])
        
            for count in 1...16 {
                if settings.chordsSum == .random && reYesNo() {
                    if count <= 8 && count >= 5 {
                        reStrings.0.append("")
                        reStrings.1.append("")
                        reStrings.4.append(-1)
                        continue
                    } else if count >=  13 {
                        reStrings.2.append("")
                        reStrings.3.append("")
                        reStrings.5.append(-1)
                        continue
                    }
                }
                
                if count <= 8 {
                    let chordData = getChord()
                    reStrings.0.append(chordData.0)
                    reStrings.1.append(chordData.1)
                    reStrings.4.append(chordData.2)
                } else {
                    let chordData = getChord()
                    reStrings.2.append(chordData.0)
                    reStrings.3.append(chordData.1)
                    reStrings.5.append(chordData.2)
                }
                
                if count <= 8 {
                    if settings.chordsSum == .one {
                        if checkIfStringInThere(firstArray:
                                                    convertToEnumArray(reStrings.0, reStrings.4), secondArray: hasToChordsArray, true) {
                            comesFromLine = .first
                        }
                    } else {
                        if checkIfStringInThere(firstArray:
                                                    convertToEnumArray(reStrings.0, reStrings.4), secondArray: hasToChordsArray, false) {
                            comesFromLine = .first
                        }
                    }
                } else if count > 8 {
                    if settings.chordsSum == .one {
                        if checkIfStringInThere(firstArray:
                                                    convertToEnumArray(reStrings.2, reStrings.5), secondArray: hasToChordsArray, true) {
                            if comesFromLine == .first {
                                comesFromLine = .both
                            } else if comesFromLine == .both {
                                comesFromLine = .both
                            } else {
                                comesFromLine = .second
                            }
                        }
                    } else {
                        if checkIfStringInThere(firstArray:
                                                    convertToEnumArray(reStrings.2, reStrings.5), secondArray: hasToChordsArray, false) {
                            if comesFromLine == .first {
                                comesFromLine = .both
                            } else if comesFromLine == .both {
                                comesFromLine = .both
                            } else {
                                comesFromLine = .second
                            }
                        }
                    }
                }
            }
            
            if comesFromLine == .first && hastToInFirstLine && !settings.hasToEveryLine {
                break
            } else if !hastToInFirstLine && comesFromLine == .second && !settings.hasToEveryLine {
                break
            } else if settings.hasToEveryLine && comesFromLine == .both {
                break
            }
            comesFromLine = .none

            if hasToChordsArray.isEmpty {
                break
            }
        }
        
        if settings.chordsSum == .random {
            var countHowMany = 0
            for intFromDegree in reStrings.4 {
                if intFromDegree == -1 {
                    countHowMany += 1
                }
            }
            for intFromDegree in reStrings.5 {
                if intFromDegree == -1 {
                    countHowMany += 1
                }
            }
            if countHowMany == 4 {
                return reStrings
            } else {
                return reChordsState()
            }
        }
        return reStrings
    }
    
    func convertToEnumArray(_ chordNames: [String], _ whichScales: [Int]) -> [(String, Int)] {
        var reEnumArray: [(String, Int)] = []
        
        for (index, chordName) in chordNames.enumerated() {
            reEnumArray.append((chordName, whichScales[index]))
        }
        return reEnumArray
    }
    
    func checkIfStringInThere(firstArray: [(String, Int)], secondArray: [(String, Int)], _ onlyFirst4: Bool) -> Bool {
        for (count1, firstArrayElem) in firstArray.enumerated() {
            for secondArrayElem in secondArray {
                if firstArrayElem == secondArrayElem && !onlyFirst4 {
                    return true
                } else if firstArrayElem == secondArrayElem && count1 < 4 {
                    return true
                }
            }
        }
        return false
    }
    
    func getFromAllChord(whichScale: Int, whichChord: Int) -> String {
        var chordCount = 0
        
        var chordLetters = ""
        for letter in allChords[whichScale] {
            if letter == "|" {
                chordCount += 1
                if chordCount == whichChord + 1 {
                    break
                }
                chordLetters = ""
            } else {
                chordLetters.append(letter)
            }
        }
        
        return chordLetters
    }
    
    func getChord() -> (String, String, Int) {
        if chords.0.count == 0 {
            return ("", "", 0)
        }
        print(chords.2.count)
        let randomInt = Int.random(in: 0..<chords.0.count)
        return (chords.0[randomInt], chords.1[randomInt], chords.2[randomInt])
    }
    
    func allChordGen() -> [String] {
        var reAllChord = [String]()
        //https://learningmusic.ableton.com/de/advanced-topics/building-major-scales.html
        reAllChord = [
            "C△|D-7|E-7|F△|G7|A-7|Bø",
            "D♭△|E♭-7|F-7|G♭△|A♭7|B♭-7|Cø",
            "D△|E-7|F♯-7|G△|A7|B-7|C♯ø",
            "E♭△|F-7|G-7|A♭△|B♭7|C-7|Dø",
            "E△|F♯-7|G♯-7|A△|B7|C♯-7|D♯ø",
            "F△|G-7|A-7|B♭△|C7|D-7|Eø",
            "F♯△|G♯-7|A♯-7|B△|C♯7|D♯-7|E♯ø",
            "G△|A-7|B-7|C△|D7|E-7|F♯ø",
            "A♭△|B♭-7|C-7|D♭△|E♭7|F-7|Gø",
            "A△|B-7|C♯-7|D△|E7|F♯-7|G♯ø",
            "B♭△|C-7|D-7|E♭△|F7|G-7|Aø",
            "B△|C♯-7|D♯-7|E△|F♯7|G♯-7|A♯ø",
            
            "Co|E♭o|F#o|Ao|B7⁽ᵇ⁹⁾|D7⁽ᵇ⁹⁾|F7⁽ᵇ⁹⁾|A♭7⁽ᵇ⁹⁾",
            "D♭o|Eo|Go|B♭o|C7⁽ᵇ⁹⁾|E♭7⁽ᵇ⁹⁾|G♭7⁽ᵇ⁹⁾|A7⁽ᵇ⁹⁾",
            "Do|Fo|A♭o|Bo|B♭7⁽ᵇ⁹⁾|C♯7⁽ᵇ⁹⁾|E7⁽ᵇ⁹⁾|G7⁽ᵇ⁹⁾",

            "C7+|D7+|E7+|F♯7+|G♯7+|A♯7+",
            "C♯7+|D♯7+|F7+|G7+|A7+|B7+",
            
            "C-6|Aø|Balt|C-△|E♭|F|G",
            "D♭-6|B♭ø|Calt|D♭-△|E|G♭|A♭",
            "D-6|Bø|C♯alt|D-△|F|G△|A",
            "E♭-6|Cø|Dalt|E♭-△|G♭|A♭|B♭",
            "E-6|C♯ø|D♯alt|E-△|G|A|B",
            "F-6|Dø|Ealt|F-△|A♭|B♭|C",
            "F♯-6|D♯ø|E♯alt|F♯-△|A|B|C♯",
            "G-6|Eø|F♯alt|G-△|A♯|C|D",
            "A♭-6|Fø|Galt|A♭-△|B|D♭|E♭",
            "A-6|F♯ø|G♯alt|A-△|C|D|E",
            "B♭-6|Gø|Aalt|B♭-△|D♭|E♭|F",
            "B-6|G♯ø|A♯alt|B-△|D|E|F♯",
        ]
        return reAllChord
    }
    
    
}

struct SettingsData {
    var chordsSum: ChordsSum = .random
    var rowCount: RowCount = .one
    var learnMode: LearnMode = .none
    var selectedChords: String = ""
    var useDegree = false
    var hasToEveryLine = true
}

struct Settings: View {
    @Binding var selectedChords: String
    @Binding var hasTochords: String

    @Binding var settings: SettingsData
    
    @Binding var learnRange: Int
    @State private var learnRangeState: String = ""

    @State private var chordSum: ChordsSum = .one
    @State private var rowCount: RowCount = .one
    @State private var learnMode: LearnMode = .none

    @State private var chordString: String = ""
    @State private var useDegree = false
    @State private var hasToEveryLine = false

    var body: some View {
        VStack {
            Picker(selection: $chordSum, label: Text(""), content: {
                Text("One").tag(ChordsSum.one)
                Text("Two").tag(ChordsSum.two)
                Text("Random").tag(ChordsSum.random)
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 20)
            
            Picker(selection: $rowCount, label: Text(""), content: {
                Text("One").tag(RowCount.one)
                Text("Double").tag(RowCount.double)
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 20)
            
            Picker(selection: $learnMode, label: Text(""), content: {
                Text("None").tag(LearnMode.none)
                Text("Random Note").tag(LearnMode.randomNotes)
                Text("Random Num").tag(LearnMode.randomNumber)
                Text("T. R. Notes").tag(LearnMode.twoRandomNotes)
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 20)
            
            Toggle(isOn: $useDegree, label: {Text("Use Degree")})
            Toggle(isOn: $hasToEveryLine, label: {Text("Use has to every line")})

            TextField("Selected chords", text: $selectedChords, onEditingChanged: { (returnType) in }, onCommit: {})
            
            TextField("Has to chords", text: $hasTochords, onEditingChanged: { (returnType) in }, onCommit: {})

            TextField("Range", text: $learnRangeState, onEditingChanged: { (returnType) in }, onCommit: {})
                .keyboardType(.numberPad)

            Spacer()
        }
        .onAppear {
            chordSum = settings.chordsSum
            rowCount = settings.rowCount
            useDegree = settings.useDegree
            hasToEveryLine = settings.hasToEveryLine
            learnMode = settings.learnMode
            learnRangeState = String(learnRange)
        }
        .onChange(of: chordSum, perform: { newValue in
            settings.chordsSum = newValue
            UserDefaults.standard.set(newValue.getAsInteger(), forKey: "chordSum")
        })
        .onChange(of: rowCount, perform: { newValue in
            settings.rowCount = newValue
            UserDefaults.standard.set(newValue.getAsInteger(), forKey: "rowCount")
        })
        .onChange(of: useDegree, perform: { newValue in
            settings.useDegree = newValue
            UserDefaults.standard.set(newValue, forKey: "useDegree")
        })
        .onChange(of: hasToEveryLine, perform: { newValue in
            settings.hasToEveryLine = newValue
            UserDefaults.standard.set(newValue, forKey: "hasToEveryLine")
        })
        .onChange(of: learnMode, perform: { newValue in
            settings.learnMode = newValue
            UserDefaults.standard.set(newValue.getAsInteger(), forKey: "learnMode")
        })
        .onChange(of: learnRangeState, perform: { newValue in
            if let tmpRange = Int(newValue) {
                learnRange = tmpRange
            } else {
                learnRange = 0
            }
        })
    }
}

struct PercSize {
    static func width(_ percent: Float) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        return screenSize.width / 100 * CGFloat(percent)
    }
    
    static func heigth(_ percent: Float) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        return screenSize.height / 100 * CGFloat(percent)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
