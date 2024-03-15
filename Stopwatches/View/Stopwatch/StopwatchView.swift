//
//  StopwatchView.swift
//  Stopwatches
//
//  Created by Matsulenko on 05.02.2024.
//

import CoreData
import SwiftUI

struct StopwatchView: View {
    
    @State var stopwatches: [StopwatchData] = []
    var predicate: NSPredicate?
    @State private var startAllButtonIsShown = false
    @AppStorage("isCompact") var isCompact = true
    var maxCount = 10
    @State private var alertShowing = false
    @State private var alertText = ""
    @State private var chosenIndex: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        ForEach($stopwatches.indices, id: \.self) { index in
                            if stopwatches[index].status != .deleted {
                                Stopwatch(stopWatchUnit: $stopwatches[index], isCompact: $isCompact) { hide in
                                    if hide {
                                        startAllButtonIsShown = false
                                    } else {
                                        showStartAllButton()
                                    }
                                }
                                    .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                        return -viewDimensions.width
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteStopwatch(id: stopwatches[index].id)
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button() {
                                            chosenIndex = index
                                            alertText = stopwatches[index].name
                                            alertShowing.toggle()
                                        } label: {
                                            Text("Name")
                                        }
                                        .tint(.indigo)
                                    }
                            }
                        }
                        HStack {
                            if stopwatches.filter({$0.status != .deleted}).count < maxCount {
                                Spacer()
                                Button(
                                    action: {
                                        newStopwatch()
                                    },
                                    label: {
                                        HStack {
                                            Image(systemName: "plus.circle")
                                            Text("Add")
                                        }
                                    })
                                .buttonStyle(
                                    DefaultButton(
                                        backgroundColor: Color.gray,
                                        textColor: Color.white,
                                        width: 150
                                    )
                                )
                                Spacer()
                            }
                        }
                        .frame(height: 50)
                        .listRowSeparator(.hidden)
                        .padding(.bottom, 80)
                            
                    }
                    .listStyle(.plain)
                }
                if startAllButtonIsShown {
                    if let firstSwIsActive = firstSwIsActive() {
                        StartAllButton(allStarted: firstSwIsActive) {
                            for i in 0..<stopwatches.count {
                                stopwatches[i].startAll = true
                            }
                        }
                    }
                }
            }
            .alert("Enter your stopwatch name", isPresented: $alertShowing) {
                TextField("Stopwatch name", text: $alertText)
                    .foregroundStyle(Color.text)
                    .background(Color.background)
                Button("OK", role: .cancel) {
                    guard let chosenIndex else { return }
                    stopwatches[chosenIndex].name = alertText
                    saveStopwatch(stopwatch: stopwatches[chosenIndex])
                }
            }
            .navigationTitle("Stopwatches")
            .toolbar {
                ToolbarItem {
                    Button {
                        isCompact.toggle()
                    } label: {
                        if isCompact {
                            Image(systemName: "list.bullet.circle.fill")
                        } else {
                            Image(systemName: "list.bullet.circle")
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchStopwatches()
            showStartAllButton()
        }
        .onChange(of: stopwatches) { _ in
            showStartAllButton()
        }
        .onChange(of: alertShowing) { _ in
            showStartAllButton()
        }
    }
    
    private func firstSwIsActive() -> Bool? {
        guard let firstSW = stopwatches.first(where: { $0.status != .deleted }) else { return nil }
        
        if firstSW.status == .active {
            return true
        } else {
            return false
        }
    }
    
    private func showStartAllButton() {
        if alertShowing {
            startAllButtonIsShown = false
        } else {
            let shownSW = stopwatches.filter({$0.status != .deleted}).map {
                switch $0.status {
                case .new, .zero:
                    var newItem = $0
                    newItem.status = .paused
                    return newItem
                default:
                    return $0
                }
            }
            
            if shownSW.count > 1 {
                if shownSW.allEqual(by: \.status) {
                    startAllButtonIsShown = true
                } else {
                    startAllButtonIsShown = false
                }
            } else {
                startAllButtonIsShown = false
            }
        }
    }
    
    private func fetchStopwatches() {
        if stopwatches.count == 0 {
            CoreDataServiceSW.shared.fetchSW(predicate: predicate) { [self] result in
                switch result {
                case .success(let fetchedData):
                    if fetchedData.count > 0 {
                        stopwatches = fetchedData.sorted(by: {$0.creationDate < $1.creationDate})
                    } else {
                        newStopwatch()
                    }
                case .failure(.custom(reason: let reason)):
                    print(reason)
                default:
                    print("Something went wrong")
                }
            }
        }
    }
    
    private  func deleteStopwatch(id: String) {
        if let x = stopwatches.firstIndex(where: {$0.id == id}) {
            CoreDataServiceSW.shared.deleteSW(id: id) { result in
                stopwatches[x].status = .deleted
                if result != .success(true) {
                    print("Deletion was failed")
                }
            }
        }
    }
    
    private func newStopwatch() {
        let number: Int = {
            if let lastIndex = stopwatches.lastIndex(where: {$0.status != .deleted}) {
                return stopwatches[lastIndex].num + 1
            } else {
                return 1
            }
        }()
        
        let newSW = StopwatchData(id: UUID().uuidString, status: .new, name: "", accumulatedTime: 0, creationDate: Date(), num: number)
        stopwatches.append(newSW)
    }
    
    private func saveStopwatch(stopwatch: StopwatchData) {
        CoreDataServiceSW.shared.saveSW(stopwatch: stopwatch) { result in
            if result != .success(true) {
                print("Saving was failed")
            }
        }
    }
}

#Preview {    
    StopwatchView(stopwatches: [StopwatchData(
        id: UUID().uuidString,
        status: .zero,
        name: "",
        accumulatedTime: 0,
        creationDate: Date(),
        num: 1
    )])
}
