//
//  ViewController.swift
//  KeyboardShortcutRecorderSample
//
//  Created by John Brayton on 9/22/24.
//

import UIKit
import KeyboardShortcutRecorderForUIKit

let savedShortcutDefaultsKey = "my_shortcut_key"

class ViewController: UIViewController {
    
    // MARK: Storing and reading the keyboard shortcut.

    var myShortcut: KEYKeyboardShortcut? = readShortcutFromDefaults() {
        didSet {
            if myShortcut != oldValue {
                let encoded = try! JSONEncoder().encode(myShortcut)
                UserDefaults.standard.set(encoded, forKey: savedShortcutDefaultsKey)
            }
        }
    }

    static func readShortcutFromDefaults() -> KEYKeyboardShortcut? {
        if let data = UserDefaults.standard.object(forKey: savedShortcutDefaultsKey) as? Data, let decoded = try? JSONDecoder().decode(KEYKeyboardShortcut.self, from: data) {
            return decoded
        } else {
            return nil
        }
    }
    
    // MARK: Setup
    
    @ViewLoading
    var keyboardShortcutField: KEYKeyboardShortcutField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keyboardShortcutField = KEYKeyboardShortcutField()
        self.keyboardShortcutField.translatesAutoresizingMaskIntoConstraints = false
        self.keyboardShortcutField.shortcut = self.myShortcut
        self.keyboardShortcutField.shortcutFieldDelegate = self
        self.view.addSubview(self.keyboardShortcutField)
        self.view.addConstraints([
            self.keyboardShortcutField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100.0),
            self.keyboardShortcutField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
        
    }
    
    // MARK: Key Command
    
    override var keyCommands: [UIKeyCommand]? {
        get {
            var result = [UIKeyCommand]()
            if let shortcut = myShortcut {
                let functionKeyCommand = UIKeyCommand(input: shortcut.input, modifierFlags: shortcut.modifierFlags, action: #selector(handleKeyCommand(_:)))
                result.append(functionKeyCommand)
            }
            return result
        }
    }
    
    @objc func handleKeyCommand( _ input: UIKeyCommand ) {
        let alert = UIAlertController(title: String.localizedStringWithFormat("Got Key Command"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String.localizedStringWithFormat("OK"), style: .default))
        self.present(alert, animated: true)
    }
    
}

// MARK: KEYKeyboardFieldDelegateType

extension ViewController : KEYKeyboardFieldDelegateType {

    func setShortcut( shortcut: KEYKeyboardShortcut? ) async -> Bool {
        self.myShortcut = shortcut
        return true
    }
    
}
