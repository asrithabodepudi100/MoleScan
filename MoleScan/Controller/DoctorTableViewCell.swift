//
//  DoctorTableViewCell.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/5/20.
//

import UIKit
import RealmSwift
protocol GrowingCellProtocol: class {
    func updateHeightOfRow(_ cell: DoctorTableViewCell, _ textView: UITextView)
}

class DoctorTableViewCell: UITableViewCell {
    weak var cellDelegate: GrowingCellProtocol?

    @IBOutlet weak var doctorTableViewCellView: UIView!
    @IBOutlet weak var doctorTypeTextView: UITextView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var phoneNumberTextView: UITextView!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doctorTableViewCellView.layer.cornerRadius = 15
        
        doctorTypeTextView.layer.cornerRadius = 9
        nameTextView.layer.cornerRadius = 9
        emailTextView.layer.cornerRadius = 9
        phoneNumberTextView.layer.cornerRadius = 9
        notesTextView.layer.cornerRadius = 9
        
        doctorTypeTextView.tintColor = #colorLiteral(red: 0.6116471291, green: 0.6115076542, blue: 0.6280091405, alpha: 1)
        nameTextView.tintColor = #colorLiteral(red: 0.4901400805, green: 0.4902282953, blue: 0.4901344776, alpha: 1)
        emailTextView.tintColor = #colorLiteral(red: 0.4901400805, green: 0.4902282953, blue: 0.4901344776, alpha: 1)
        phoneNumberTextView.tintColor = #colorLiteral(red: 0.4901400805, green: 0.4902282953, blue: 0.4901344776, alpha: 1)
        notesTextView.tintColor = #colorLiteral(red: 0.4901400805, green: 0.4902282953, blue: 0.4901344776, alpha: 1)
        
        doctorTypeTextView.spellCheckingType = UITextSpellCheckingType.no
        nameTextView.spellCheckingType = UITextSpellCheckingType.no
        emailTextView.spellCheckingType = UITextSpellCheckingType.no
        phoneNumberTextView.spellCheckingType = UITextSpellCheckingType.no
        notesTextView.spellCheckingType = UITextSpellCheckingType.no

        doctorTypeTextView.delegate = self
        nameTextView.delegate = self
        emailTextView.delegate = self
        phoneNumberTextView.delegate = self
        notesTextView.delegate = self

     /*   doctorTypeTextView.selectedTextRange = doctorTypeTextView.textRange(from: doctorTypeTextView.beginningOfDocument, to: doctorTypeTextView.beginningOfDocument)
        nameTextView.selectedTextRange = nameTextView.textRange(from: nameTextView.beginningOfDocument, to: nameTextView.beginningOfDocument)
        emailTextView.selectedTextRange = emailTextView.textRange(from: emailTextView.beginningOfDocument, to: emailTextView.beginningOfDocument)
        phoneNumberTextView.selectedTextRange = phoneNumberTextView.textRange(from: phoneNumberTextView.beginningOfDocument, to: phoneNumberTextView.beginningOfDocument)
        notesTextView.selectedTextRange = notesTextView.textRange(from: notesTextView.beginningOfDocument, to: notesTextView.beginningOfDocument)*/

      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


extension DoctorTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let deletate = cellDelegate {
            deletate.updateHeightOfRow(self, textView)
        }
    }
}
