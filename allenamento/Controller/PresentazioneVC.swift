//
//  PresentazioneVC.swift
//  allenamento
//
//  Created by Enrico on 02/05/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit

class PresentazioneVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "PresentationDone91")
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        let txt = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35)])
        
        txt.append(NSMutableAttributedString(string: "Fit Clash", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 45, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.systemIndigo]))
        
        txt.append(NSMutableAttributedString(string: NSLocalizedString(" ti dà il benvenuto", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 45, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.label]))
        titolo.attributedText = txt
        
        let sez1T = NSMutableAttributedString(string: NSLocalizedString("Allena gli addominali", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.label])
        
        sez1T.append(NSMutableAttributedString(string: NSLocalizedString("\nProgramma giornaliero e sessioni libere, incrocia le braccia sul petto e tieni il telefono con una delle due mani, il conteggio degli addominali sarà automatico", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.label]))
        sez1.attributedText = sez1T
        
        let sez2T = NSMutableAttributedString(string: NSLocalizedString("Allena le flessioni", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.label])
        
        sez2T.append(NSMutableAttributedString(string: NSLocalizedString("\nProgramma giornaliero e sessioni libere, poni il telefono a terra in linea con la tua testa e tocca il telefono con il naso ad ogni flessione, il conteggio sarà automatico", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.label]))
        sez2.attributedText = sez2T
        let sez3T = NSMutableAttributedString(string: NSLocalizedString("Sfida i tuoi amici", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.label])
        
        sez3T.append(NSMutableAttributedString(string: NSLocalizedString("\nAggiungi amici e sfidali grazie ad una classifica divisa in periodi e tipi di esercizio e guarda la frequenza dei loro allenamenti grazie ad un feed personalizzato", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.label]))
        sez3.attributedText = sez3T
        
        
        titolo.translatesAutoresizingMaskIntoConstraints = true
        titolo.sizeToFit()
        titolo.isScrollEnabled = false
        
        sez1.translatesAutoresizingMaskIntoConstraints = true
        sez1.sizeToFit()
        sez1.isScrollEnabled = false
        
        sez2.translatesAutoresizingMaskIntoConstraints = true
        sez2.sizeToFit()
        sez2.isScrollEnabled = false
        
        sez3.translatesAutoresizingMaskIntoConstraints = true
        sez3.sizeToFit()
        sez3.isScrollEnabled = false
        
        gooo.setTitle(NSLocalizedString("Iniziamo", comment: ""), for: .normal)
        
        
    }
    @IBOutlet weak var gooo: UIButton!
    
    @IBAction func iniziamoButton(_ sender: Any) {
        print("to add")
        self.performSegue(withIdentifier: "toAddFPRES", sender: nil)
    }
    
    
    @IBOutlet weak var titolo: UITextView!
    @IBOutlet weak var sez1: UITextView!
    @IBOutlet weak var sez2: UITextView!
    @IBOutlet weak var sez3: UITextView!
    
}
