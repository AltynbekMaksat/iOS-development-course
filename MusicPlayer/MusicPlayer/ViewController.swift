
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    var audioPlayer: AVAudioPlayer?
    var songs = ["song1", "song2"]
    var currentSongIndex = 0
    var timer: Timer?
    
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverImageView.layer.cornerRadius = 12
        coverImageView.clipsToBounds = true
        
        previousButton.setTitle("⏮️", for: .normal)
        nextButton.setTitle("⏭️", for: .normal)
        playPauseButton.setTitle("▶️", for: .normal)
        
        progressSlider.minimumValue = 0
        progressSlider.value = 0
        
        currentTimeLabel.text = "0:00"
        durationLabel.text = "0:00"
        
        loadSong()
    }
    
    
    func loadSong() {
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        
        let songName = songs[currentSongIndex]
        
        guard let url = Bundle.main.url(
            forResource: songName,
            withExtension: "mp3"
        ) else {
            print("MP3 file not found: \(songName)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayer = player
            
            titleLabel.text = songName
            artistLabel.text = "Unknown Artist"
            
            let duration = player.duration
            
            progressSlider.minimumValue = 0
            progressSlider.maximumValue = Float(max(duration, 1))
            progressSlider.value = 0
            
            currentTimeLabel.text = formatTime(0)
            durationLabel.text = formatTime(duration)
            
            playPauseButton.setTitle("▶️", for: .normal)
            
            print("Song duration: \(duration) seconds")
        } catch {
            print("Audio error: \(error)")
        }
    }
    
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = audioPlayer else {
            return
        }
        
        if player.isPlaying {
            player.pause()
            timer?.invalidate()
            timer = nil
            
            sender.setTitle("▶️", for: .normal)
        } else {
            if player.currentTime >= player.duration {
                player.currentTime = 0
            }
            
            player.play()
            sender.setTitle("⏸️", for: .normal)
            startTimer()
        }
    }
    
    
    @IBAction func nextTapped(_ sender: UIButton) {
        currentSongIndex = (currentSongIndex + 1) % songs.count
        
        loadSong()
        
        audioPlayer?.play()
        playPauseButton.setTitle("⏸️", for: .normal)
        startTimer()
    }
    
    
    @IBAction func previousTapped(_ sender: UIButton) {
        currentSongIndex =
        (currentSongIndex - 1 + songs.count) % songs.count
        
        loadSong()
        
        audioPlayer?.play()
        playPauseButton.setTitle("⏸️", for: .normal)
        startTimer()
    }
    
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    
    func updateProgress() {
        guard let player = audioPlayer else { return }
        
        let currentTime = player.currentTime
        let duration = player.duration
        
        progressSlider.maximumValue = Float(max(duration, 1))
        progressSlider.value = Float(currentTime)
        
        currentTimeLabel.text = formatTime(currentTime)
        durationLabel.text = formatTime(duration)
        
        if currentTime >= duration {
            timer?.invalidate()
            timer = nil
            playPauseButton.setTitle("▶️", for: .normal)
        }
    }
        
    @IBAction func sliderChanged(_ sender: UISlider) {
        guard let player = audioPlayer else {
            return
        }
        
        player.currentTime = TimeInterval(sender.value)
        updateProgress()
    }
    
    
    func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(0, Int(time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}
