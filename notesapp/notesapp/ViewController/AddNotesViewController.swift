//
//  AddNotesViewController.swift
//  notesapp
//
//  Created by admin on 6/14/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import AVFoundation

class AddNotesViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate{
    
    var managedContext: NSManagedObjectContext!
    let locationManager = CLLocationManager()

    @IBOutlet weak var noteLong: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    //@IBOutlet weak var doneButton: UIButton!
    //@IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var recordAudio: UIButton!
    @IBOutlet weak var playAudio: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
   // @IBOutlet weak var mapViewSegment: UISegmentedControl!
    var selectedNote: Note!
    var location: CLLocation!
    var latitude: Double!
    var longitude: Double!
    var locationStr: String = ""
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var session: AVAudioSession!
    var currentDate = Date()
    var fileName = ""
    var filePath: URL!
    var isNew: Bool!
    
    override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
            //noteLong.delegate = self
        session = AVAudioSession.sharedInstance()
        AVAudioSession.sharedInstance().requestRecordPermission{ (hasPermission) in
            if hasPermission{
                print("granted")
            }
        }
            recordAudio.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            playAudio.setImage(UIImage(systemName: "play.fill"), for: .normal)
            doneButton.isHidden = true
            noteLong.becomeFirstResponder()
            locationManager.delegate = self
        
        //if the note is not new
            if selectedNote != nil{
                isNew = false
                noteLong.text = selectedNote.title
                location = CLLocation(latitude: selectedNote.noteLatitude, longitude: selectedNote.noteLongitude)
                //locationLabel.isHidden = false
                locationLabel.text = selectedNote.locationString
                //print(selectedNote.locationString)
                locationButton.isHidden = false
                if selectedNote.image != nil{
                    
                imageView.image = UIImage(data: selectedNote.image! as Data)
                } else{
                    print("no image while loading")
                }
                
                if selectedNote.audioName != nil{
                    fileName = selectedNote.audioName!
                    //recorderFunction()
                    print("when note is there", fileName)
                    playAudio.isHidden = false
                } else{
                    playAudio.isHidden = true
                    let dateFormatter = DateFormatter()
                    dateFormatter.setLocalizedDateFormatFromTemplate("H:m:ss")
                                   
                    fileName = dateFormatter.string(from: selectedNote.date!) + "audio.m4a"
                    
                    print("no aduio while loading")
                }
                
            }//when note is new
            else if selectedNote == nil{
                isNew = true
                noteLong.text = "Add Note..."
                getLocation()
                currentDate = Date()
                locationLabel.text = ""
                locationButton.isHidden = true
                playAudio.isHidden = true
                let dateFormatter = DateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("H:m:ss")
                               
                fileName = dateFormatter.string(from: currentDate) + "audio.m4a"
                //fileName = "audio.m4a"
                //recorderFunction()
                print("new note", fileName)
                           
            }
        
        //recorderFunction()
        
        }
    
    @objc func getLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last{
            latitude = newLocation.coordinate.latitude
            longitude = newLocation.coordinate.longitude
            location = newLocation
            print("This is my loaction", location.coordinate.latitude)
        }
    }
        
            
        
    @IBAction func cameraButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
            }else{
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action:UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.imageView.isHidden = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet,animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // for audio recording
    
    
    @IBAction func recordBtnAction(_ sender: Any) {
        
        if (recordAudio.currentImage!.isEqual(UIImage(systemName: "mic.fill"))){
            //recorder.record()
            print("recording")
            recordAudio.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            let audioFile = getDocumentsDirector().appendingPathComponent(fileName)
            var settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue]
            
            do{
                recorder = try AVAudioRecorder(url: audioFile, settings: settings)
                recorder.delegate = self
                recorder.record()
                print("URL of recorder", audioFile)
            } catch{
                print("recorder error", error)
            
            }
            //recorder.record()
            playAudio.isEnabled = false
            playAudio.isHidden = false
            
        } else {
            recorder.stop()
            print("recording stopped")
            recordAudio.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            //playAudio.isHidden = false
            playAudio.isEnabled = true
        }
    }
    
    func getDocumentsDirector() -> URL {
        if isNew{
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        filePath = path[0]
        return path[0]
        } else if !isNew{
            if selectedNote.audioUrl == nil{
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                filePath = path[0]
                return path[0]
            }else{
                //filePath = selectedNote.audioUrl
                let path = selectedNote.audioUrl
                print("old file path", filePath)
                //return selectedNote.audioUrl!
                return path!
                
            }
        }
        return selectedNote.audioUrl!
    }
    
    @IBAction func playBtnAction(_ sender: Any) {
        
        let audioFile = getDocumentsDirector().appendingPathComponent(fileName)
        print("url", audioFile)
        
        do{
            player = try AVAudioPlayer(contentsOf: audioFile)
            player.prepareToPlay()
            player.delegate = self
            player.play()
             
        if (playAudio.currentImage!.isEqual(UIImage(systemName: "play.fill"))){
                
                print("playing")
                playAudio.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                
                recordAudio.isEnabled = false
                
                
            } else {
                player.stop()
                playAudio.setImage(UIImage(systemName: "play.fill"), for: .normal)
                //playAudio.isHidden = false
                recordAudio.isEnabled = true
            }
            } catch {
                print("plaer error", error)
               print("URL of player", audioFile)
            }
        
    }
    
    //save note
        @IBAction func addButtonAction(_ sender: Any) {
            
            guard let title = noteLong.text, !title.isEmpty else{
                print("Note written")
                return
            }

            if selectedNote == nil{
                let note = Note(context: managedContext)
                note.title = title
                note.noteLatitude = location.coordinate.latitude as! Double
                note.noteLongitude = location.coordinate.longitude as! Double
                location.fetchCityCountry{
                    city, country, error in
                    guard let city = city, let country = country, error == nil else{ return }
                    self.locationStr = String(city + ", " + country)
                    print(self.locationStr)
                
                    note.locationString = self.locationStr
                }
                //print(note.locationString)
                note.date = currentDate
                if imageView.image != nil{
                note.image = (imageView.image?.jpegData(compressionQuality: 1)!)! as NSData as Data
                } else{
                    print("no image while saving")
                }
                
                // for audio saving
                
                if !playAudio.isHidden {
                    
                    note.audioName = fileName
                    note.audioUrl = filePath
                                       
                } else{
                    print("no audio while saving")
                }
                
                selectedNote = note
                do{
                    try managedContext.save()
                    dismiss(animated: true)
                    
                    noteLong.resignFirstResponder()
                } catch{
                    print("Error while saving newnote")
                }
            }else{
                selectedNote.title = noteLong.text
                if imageView.image != nil{
                selectedNote.image = (imageView.image?.jpegData(compressionQuality: 1)!)! as NSData as Data
                } else{
                    print("no image while saving")
                }
                
                if !playAudio.isHidden {
                    
                    selectedNote.audioName = fileName
                    selectedNote.audioUrl = filePath
                                       
                } else{
                    print("no audio while saving")
                }
                
                
    
                
            do{
                try managedContext.save()
                dismiss(animated: true)
                noteLong.resignFirstResponder()
                var alert = UIAlertController(title: "Edited", message: "Edit is saved", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } catch{
                print("Error while saving note")
            }
            }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIButton, let vc = segue.destination as? MapViewController {
            vc.location = location
        }
    }
    }
        
        extension AddNotesViewController: UITextViewDelegate{
            func textViewDidChangeSelection(_ textView: UITextView) {
                if doneButton.isHidden{
                    
                    doneButton.isHidden = false
                }
            }
        }

extension CLLocation{
    func fetchCityCountry(completion: @escaping(_ city: String?, _ country: String?, _ error: Error?) -> ()){
        CLGeocoder().reverseGeocodeLocation(self) {
            completion($0?.first?.locality, $0?.first?.country, $1)
        }
        
    }
}

