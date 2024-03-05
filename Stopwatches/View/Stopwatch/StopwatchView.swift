//
//  StopwatchView.swift
//  Stopwatches
//
//  Created by Matsulenko on 05.02.2024.
//

import CoreData
import SwiftUI

struct StopwatchView: View {
    
    private var predicate: NSPredicate?
    @State var stopwatches: [StopwatchData] = []
    @State private var startAllButtonIsShown = false
    @AppStorage("isCompact") var isCompact = false
    private var maxCount = 10
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(stopwatches.indices, id: \.self) { index in
                        Stopwatch(stopWatchUnit: $stopwatches[index], isCompact: $isCompact)
                            .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                                return -viewDimensions.width
                                            }
                    }
                    .onDelete { index in
                        deleteStopwatch(indexSet: index)
                    }
                    
                    VStack {
                        HStack {
                            if stopwatches.count <= maxCount {
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
                        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return -viewDimensions.width
                        }
                        .padding(.bottom, 80)
                    }
                }
                .listStyle(.plain)
                        
                if startAllButtonIsShown {
                    if let allStarted = stopwatches.first?.isRunning {
                        StartAllButton(allStarted: allStarted) {
                            for i in 0..<stopwatches.count {
                                stopwatches[i].startAll = true
                            }
                        }
                    }
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
    }
    
    func showStartAllButton() {
        if stopwatches.count > 1 {
            if stopwatches.allEqual(by: \.isRunning) {
                startAllButtonIsShown = true
            } else {
                startAllButtonIsShown = false
            }
        } else {
            startAllButtonIsShown = false
        }
    }
    
    func fetchStopwatches() {
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
    
    func deleteStopwatch(indexSet: IndexSet) {
        for i in indexSet {
            CoreDataServiceSW.shared.deleteSW(id: stopwatches[i].id) { result in
                if result != .success(true) {
                    print("Deletion was failed")
                }
            }
        }
        stopwatches.remove(atOffsets: indexSet)
    }
    
    func newStopwatch() {
        let newSW = StopwatchData(id: UUID().uuidString, isRunning: false, name: "", accumulatedTime: 0, creationDate: Date())
        stopwatches.append(newSW)
    }
}

struct UINavigationConfiguration: UIViewControllerRepresentable {
    var config: (UINavigationController) -> Void = {_ in }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            if let nc = controller.navigationController {
                self.config(nc)
            }
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

#Preview {
    StopwatchView()
}
