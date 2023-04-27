//
//  ViewController.swift
//  PomodoroTimer
//
//  Copyright (c) 2023 oasis444. All right reserved.
//

/*
 타이머 구현을 위해 Timer을 사용하면 되지만 여기서는 병렬 프로그래밍을 사용법을 익히기 위해 GCD를 사용하였습니다.
 */

import UIKit
import AudioToolbox

enum TimerState {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    var duration = 60
    var timerState: TimerState = .end
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureToggleButton()
    }


    @IBAction func tapCancelBtn(_ sender: UIButton) {
        switch self.timerState {
        case .start, .pause:
            self.stopTimer()
            
        case .end:
             break
        }
    }
    
    @IBAction func tapToggleBtn(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration) // datePicker에서 선택한 시간 알려줌
        switch self.timerState {
        case .end:
            self.currentSeconds = self.duration
            self.timerState = .start
//            self.setTimerInfoViewVisible(isHidden: false)
            UIView.animate(withDuration: 0.5) { // 부드러운 애니메이션 효과 적용
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            }
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
            
        case .start:
            self.timerState = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
            
        case .pause:
            self.timerState = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
        }
    }
    
//    private func setTimerInfoViewVisible(isHidden: Bool) {
//        self.datePicker.isHidden = !isHidden
//        self.timerLabel.isHidden = isHidden
//        self.progressView.isHidden = isHidden
//    }
    
    private func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    private func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main) // Timer가 변경될 때 마다 UI 업데이트를 해야하기 때문에 main 스레드 사용
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                let hour = self.currentSeconds / 3600
                let minite = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d : %02d : %02d", hour, minite, seconds)
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                self.currentSeconds -= 1
                UIView.animate(withDuration: 0.5, delay: 0) {
//                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                    self.imageView.transform = .init(rotationAngle: .pi) // 위와 같은 방법
                }
                UIView.animate(withDuration: 0.5, delay: 0.5) {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                }
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005) // 시스템 기본 사운드
                }
            })
            self.timer?.resume()
        }
    }
    
    private func stopTimer() {
        if self.timerState == .pause {
            self.timer?.resume() // 일시 정지 후 취소하는 경우 nil을 할당하기 위해 resume 먼저 수행
        }
        self.timerState = .end
        self.cancelButton.isEnabled = false
//        self.setTimerInfoViewVisible(isHidden: true)
        UIView.animate(withDuration: 0.5) {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        }
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil // 타이머 종료 시 nil을 할당하여 메모리에서 해제 시키기
    }
}
