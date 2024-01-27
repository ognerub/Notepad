import UIKit

final class NotesViewModel {
    @Observable
    private (set) var notesArray: [Note] = []

    private let noteStore: NoteStore
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate init error")
        }
        let noteStore = NoteStore(
            context: appDelegate.persistentContainer.viewContext)
        self.init(
            noteStore: noteStore
        )
    }

    init(
        noteStore: NoteStore
    ) {
        self.noteStore = noteStore
        
        noteStore.delegate = self
        
        notesArray = getNotes()
    }
    
    func getNotes() -> [Note] {
        return noteStore.notes
    }
    
    func addNew(note: Note) {
        try? noteStore.addNewNote(note)
    }
    
    func delete(note: Note) {
        try? noteStore.deleteSelectedNote(with: note.noteID)
    }
}

extension NotesViewModel: NoteStoreDelegate {
    func store(_ store: NoteStore, didUpdate update: NoteStoreUpdate) {
        notesArray = getNotes()
    }
}
