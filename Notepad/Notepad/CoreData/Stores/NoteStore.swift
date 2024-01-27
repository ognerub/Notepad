import UIKit
import CoreData

enum NoteStoreError: Error {
    case decodingErrorInvalidText
    case decodingErrorInvalidNoteID
    case initError
}

struct NoteStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol NoteStoreDelegate: AnyObject {
    func store(
        _ store: NoteStore,
        didUpdate update: NoteStoreUpdate
    )
}

final class NoteStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<NoteCoreData>?

    weak var delegate: NoteStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    var notes: [Note] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let trackers = try? objects.map({ try self.note(from: $0) })
        else { return [] }
        return trackers
    }
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate init error")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        fetch()
    }
    
    private func fetch() {
        let fetchRequest = NoteCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \NoteCoreData.objectID, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try? controller.performFetch()
    }
    
    func note(from noteCoreData: NoteCoreData) throws -> Note {
        guard let text = noteCoreData.text else {
            throw NoteStoreError.decodingErrorInvalidText
        }
        guard let noteID = noteCoreData.noteID else {
            throw NoteStoreError.decodingErrorInvalidNoteID
        }
        return Note(noteID: noteID, text: text)
    }
    
    func addNewNote(_ note: Note) throws {
        let noteCoreData = NoteCoreData(context: context)
        updateExistingNote(noteCoreData, with: note)
        try tryToSaveContext(from: "addNewTracker")
    }
    
    private func updateExistingNote(_ noteCoreData: NoteCoreData, with note: Note) {
        noteCoreData.text = note.text
        noteCoreData.noteID = note.noteID
    }
    
    func deleteSelectedNote(with noteID: UUID) throws {
        guard let object = fetchSelectedNote(with: context, noteID: noteID) else {
            return
        }
        context.delete(object)
        try tryToSaveContext(from: "deleteSelectedTracker")
    }
    
    func deleteAll() throws {
        let objects = fetchedResultsController?.fetchedObjects ?? []
           for object in objects { context.delete(object) }
        try context.save()
    }
    
    func createMockNote() -> Note {
        let note = Note(
            noteID: UUID(),
            text: "Mock note"
        )
        return note
    }
    
    private func fetchSelectedNote(with context: NSManagedObjectContext, noteID: UUID) -> NoteCoreData? {
        let request = NoteCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(NoteCoreData.noteID), noteID as CVarArg)
        let object = try? context.fetch(request).first
        return object
    }
    
    func tryToSaveContext(from funcName: String) throws {
        do {
            try context.save()
            print("success save")
        } catch {
            print("error save")
            return
        }
    }
    
}

extension NoteStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: NoteStoreUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet()
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            return
        case .move:
            return
        @unknown default:
            fatalError()
        }
    }
}





