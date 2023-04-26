//
//  ViewController.swift
//  PomodoroTimer
//
//  Copyright (c) 2023 oasis444. All right reserved.
//

import UIKit

enum TimerState {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    var duration = 60
    var timerState: TimerState = .end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureToggleButton()
    }


    @IBAction func tapCancelBtn(_ sender: UIButton) {
        switch self.timerState {
        case .start, .pause:
            self.timerState = .end
            self.cancelButton.isEnabled = false
            self.setTimerInfoViewVisible(isHidden: true)
            self.toggleButton.isSelected = false
            
        case .end:
             break
        }
    }
    
    @IBAction func tapToggleBtn(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration) // datePicker에서 선택한 시간 알려줌
        switch self.timerState {
        case .end:
            self.timerState = .start
            self.setTimerInfoViewVisible(isHidden: false)
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled = true
            
        case .start:
            self.timerState = .pause
            self.toggleButton.isSelected = false
            
        case .pause:
            self.timerState = .start
            self.toggleButton.isSelected = true
        }
    }
    
    private func setTimerInfoViewVisible(isHidden: Bool) {
        self.datePicker.isHidden = !isHidden
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    private func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
}

