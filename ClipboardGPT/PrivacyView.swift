//
// PrivacyView.swift
// ClipboardGPT
//
// Created by Nabin Gautam on 3/28/23.
//


import SwiftUI

struct PrivacyView: View {
    
    
    @State private var remainingTime: TimeInterval = 3600
    
    @State private var initialTime: TimeInterval = 3600
    
    @State private var timer: Timer? = nil
    
    @State private var isRunning: Bool = false
    
    @State private var timeInput: String = "1:00:00"
    
    func saveRemainingTime() {
        UserDefaults.standard.set(remainingTime, forKey: "remainingTime")
        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: "savedAt")
    }

    func loadRemainingTime() {
        let savedRemainingTime = UserDefaults.standard.double(forKey: "remainingTime")
        
        if savedRemainingTime > 0 {
            remainingTime = savedRemainingTime
        } else {
            remainingTime = timeIntervalFromString(timeInput)
        }
    }
    
    
    func timeIntervalFromString(_ time: String) -> TimeInterval {
        let timeParts = time.split(separator: ":").compactMap { Double($0) }
        
        guard timeParts.count == 3 else { return initialTime }
        
        let hours = timeParts[0] * 3600
        
        let minutes = timeParts[1] * 60
        
        let seconds = timeParts[2]
        
        return hours + minutes + seconds
        
    }
    
    func formatTimeString(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let seconds = Int(seconds) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        
    }
    
    func setupTimer() {
        if timer == nil {
            if initialTime == 0 {
                initialTime = timeIntervalFromString(timeInput)
            } else {
                // Retrieve saved progress
                let savedRemainingTime = UserDefaults.standard.double(forKey: "remainingTime")
                if savedRemainingTime > 0 {
                    initialTime = savedRemainingTime
                } else {
                    initialTime = timeIntervalFromString(timeInput)
                }
            }
            remainingTime = initialTime
        }
    }
    
    func startOrStopTimer() {
        isRunning.toggle()

        if isRunning {
            setupTimer()

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                    saveRemainingTime() // Save the remaining time on every tick
                } else {
                    timer?.invalidate()
                    isRunning = false
                }
            }
        } else {
            timer?.invalidate()
            saveRemainingTime()
        }
    }
    
    func resetTimer() {
        
        timer?.invalidate()
        
        isRunning = false
        
        remainingTime = timeIntervalFromString(timeInput)
        
        initialTime = remainingTime
        
    }
    
    var body: some View {
        
        VStack {
            Text("Focus Mode")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .foregroundColor(Color.red.opacity(0.7))
            
            ZStack {
                CircularProgress(progress: 1, color: Color.gray)
                
                    .frame(width: 150, height: 150)
                
                CircularProgress(progress: CGFloat((initialTime - remainingTime) / initialTime), color: Color.blue)
                
                    .frame(width: 150, height: 150)
                
                Text(formatTimeString(remainingTime))
                
                    .font(.system(size: 24))
                
                    .fontWeight(.bold)
                
                    .foregroundColor(Color.blue.opacity(0.7))
                
            }
            
            HStack {
                
                Button(action: startOrStopTimer) {
                    
                    Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    
                        .imageScale(.large)
                    
                }
                
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: resetTimer) {
                    
                    Image(systemName: "arrow.clockwise")
                    
                        .imageScale(.large)
                    
                }
                
                .buttonStyle(BorderlessButtonStyle())
                
            }
            
            .padding(.top)
            
            TextField("Enter time (hr:min:sec)", text: $timeInput)
            
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 120)
                .padding()
                .multilineTextAlignment(.center)
            
        }
        
        .background(Color.clear)
        .onAppear {
                loadRemainingTime()
            }
        
    }
    
}


struct PrivacyView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        
        PrivacyView()
        
    }
    
}

struct CircularProgress: View {
    
    
    let progress: CGFloat
    
    let color: Color
    
    var body: some View {
        
        Circle()
        
            .trim(from: 0, to: progress)
        
            .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
        
            .rotationEffect(.degrees(-90))
        
    }
    
}
