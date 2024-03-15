//
//  CoreDataServiceSW.swift
//  Stopwatches
//
//  Created by Matsulenko on 24.02.2024.
//

import CoreData
import Foundation

enum CoreDataError: Error, Equatable {
    case unknown
    case custom(reason: String)
}

protocol CoreDataServiceSWProtocol {
    func saveSW(stopwatch: StopwatchData, completion: @escaping (Result<Bool, CoreDataError>) -> Void)
    func fetchSW(predicate: NSPredicate?, completion: @escaping(Result<[StopwatchData], CoreDataError>) -> Void)
    func deleteSW(id: String, completion: @escaping (Result<Bool, CoreDataError>)->Void)
}

final class CoreDataServiceSW: CoreDataServiceSWProtocol {
    
    private let modelName: String
    private let objectModel: NSManagedObjectModel
    private let storeCoordinator: NSPersistentStoreCoordinator
    
    static var shared = CoreDataServiceSW()
    
    lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator
        
        return context
    }()
    
    init() {
        guard let url = Bundle.main.url(
            forResource: "StopwatchesDataModel",
            withExtension: "momd"
        ) else {
            fatalError()
        }
        
        let name = url.lastPathComponent
        modelName = name
        
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError() }
        
        objectModel = model
        
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        
        let storeName = name + "sqlite"
        let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let persistentStoreUrl = documentDirectoryUrl?.appendingPathComponent(storeName) else { return }
        
        do {
            _ = try storeCoordinator.addPersistentStore(
                type: .sqlite, at: persistentStoreUrl,
                options: [NSMigratePersistentStoresAutomaticallyOption: true]
            )
        } catch {
//            fatalError()
        }
    }
    
    func saveSW(stopwatch: StopwatchData, completion: @escaping (Result<Bool, CoreDataError>) -> Void) {
        mainContext.perform { [weak self] in
            guard let self else { return }
            
            let model = StopwatchesModel(context: mainContext)
            
            model.id = stopwatch.id
            model.status = stopwatch.status.rawValue
            model.name = stopwatch.name
            model.startDate = stopwatch.startDate
            model.accumulatedTime = stopwatch.accumulatedTime
            model.creationDate = stopwatch.creationDate
            model.num = Int16(stopwatch.num)
            
            guard mainContext.hasChanges else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                try mainContext.save()
                completion(.success(true))
            } catch {
                completion(.failure(.custom(reason: error.localizedDescription)))
            }
        }
    }
    
    func fetchSW(predicate: NSPredicate?, completion: @escaping (Result<[StopwatchData], CoreDataError>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            
            let request = StopwatchesModel.fetchRequest()
            request.predicate = predicate
            
            do {
                let models = try backgroundContext.fetch(request)
                mainContext.perform {
                    completion(.success(models.map { StopwatchData(stopwatchesModel: $0) }))
                }
            } catch {
                mainContext.perform {
                    completion(.failure(.custom(reason: error.localizedDescription)))
                }
            }
        }
    }
    
    func deleteSW(id: String, completion: @escaping (Result<Bool, CoreDataError>) -> Void) {
        mainContext.perform { [weak self] in
            guard let self else { return }
            
            let request = StopwatchesModel.fetchRequest()
            
            do {
                let models = try mainContext.fetch(request)
                let removeModels = models.filter { $0.id == id }
                removeModels.forEach {
                    self.mainContext.delete($0)
                }
                try mainContext.save()
                completion(.success(true))
            } catch {
                completion(.failure(.custom(reason: error.localizedDescription)))
            }
        }
    }
}
