import Foundation
import UIKit

protocol EditMelodyGridNoteDelegate: AnyObject {
    func editMelodyGridNoteWasTapped(_ editMelodyGridNote: EditMelodyGridNote)
}

final class EditMelodyGridNote: UIView {
    weak var delegate: EditMelodyGridNoteDelegate?
    
    let noteViewModel: NoteViewModel
    
    init(noteViewModel: NoteViewModel) {
        self.noteViewModel = noteViewModel
        
        super.init(frame: .zero)
        
        backgroundColor = .imp.complementary
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startPlayAnimation() {
        backgroundColor = .white
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = .imp.complementary
        }
    }

    @objc
    private func onTap(_ sender: UITapGestureRecognizer) {
        delegate?.editMelodyGridNoteWasTapped(self)
    }
}
