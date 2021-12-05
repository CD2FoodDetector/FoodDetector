//
//  CameraView.swift
//  FoodDetector
//
//  Created by 강다연 on 2021/10/11.
//

import SwiftUI
import AVFoundation
import PhotosUI


struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    
    @State var showImagePicker: Bool = false
    
    @State var pickerResult: UIImage = UIImage()
    
    var body: some View {

            ZStack{
                //goint to be camera preview..
                CameraPreview(camera: camera)
                //Color.black
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack{
                    
                   // if camera.isTaken{
                        
                        HStack {
                            Spacer()
                            if (camera.isTaken) && (pickerResult==UIImage()){
                                Button(action: camera.reTake, label: {
                                    Image(systemName:"arrow.triangle.2.circlepath.camera")
                                        .foregroundColor(.black)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                    
                                })
                                .padding(.leading,10)
                            }
                            else{
                                //NavigationView{
                                    NavigationLink(destination: DetectView(image: $pickerResult)){
                                        
                                            Text("음식 detect")
                                                .foregroundColor(.black)
                                                .fontWeight(.semibold)
                                                .padding(.vertical,10)
                                                .padding(.horizontal,20)
                                                .background(Color.white)
                                                .clipShape(Capsule())
                                        
                                    }
                                    .padding(.leading,10)
                                //}
                                
                            }
                        }
                        
                        Spacer()
                        
                    //}
                    
                    
                    Spacer()
                    
                    HStack{
                        
                        // if taken showing save and again take button..
                        
                        if camera.isTaken{
                            
                            Button(action: {if !camera.isSaved{pickerResult = camera.savePic()}}, label: {
                                Text(camera.isSaved ? "Saved":"Save")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .padding(.vertical,10)
                                    .padding(.horizontal,20)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            })
                            .padding(.leading,10)
                            
                            Spacer()
                            
                        }
                        else{
                            HStack{
                                
                                Spacer()
                                Spacer()
                                
                                Button(action: camera.takePic, label: {
                                    
                                    ZStack{
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 70, height: 70)
                                    }
                                })
                                
                                Spacer()
                                //picker

                                Button(action: {self.showImagePicker = true}, label: {
                                    Image(systemName:"photo.on.rectangle.angled")
                                        .foregroundColor(.black)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                    
                                })
                                
                                //.padding(.leading,10)
                                
                            }
                        }

                    }
                    .frame(height:75)
                }
            }
            .onAppear(perform: {
                camera.Check()
            })
            .sheet(isPresented: $showImagePicker, content: {
                  let configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                  PhotoPicker(configuration: configuration, pickerResult: $pickerResult, isPresented: $showImagePicker)
                })
        }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

// camera model..

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    //since we're going to read pic data..
    @Published var output = AVCapturePhotoOutput()
    
    //preview..
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    //pic data..
    @Published var isSaved = false
    
    @Published var picData = Data(count: 0)
    
    func Check(){
        // first checking camera has got permission..
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized :
            setUp()
            return
            //setting up session
        case .notDetermined :
            //retusting for permission..
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setUp()
                }
            }
        case .denied :
            self.alert.toggle()
            return
            
        default:
            return
        }
    }
    
    func setDevice() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera,
                                                for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device.")
        }
    }
    
    func setUp(){
        
        // setting up camera..
        
        do{
            
            // setting configs..
            self.session.beginConfiguration()
            
            
            //device set
            let device = setDevice()
            
            let input = try AVCaptureDeviceInput(device: device)
            
            //checking and adding to session..
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            //same for output...
            if self.session.canAddOutput(self.output){
                self.session.addOutput(output)
            }
            
            self.session.commitConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    
    //take and retake functions...
    
    func takePic(){
        
        DispatchQueue.global(qos: .background).async {
            
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                    self.session.stopRunning()
                }
            }
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
        }
    }
    
    func reTake(){
        DispatchQueue.global(qos: .background).async {
            //
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
            
            //clearing..
            DispatchQueue.main.async {
                self.isSaved.toggle()
            }
            
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil{
            return
        }
        print("pic taken...")
        
        guard let imageData = photo.fileDataRepresentation() else{return}
        
        self.picData = imageData
    }
    
    func savePic()-> UIImage {
        let image = UIImage(data: self.picData)!
        
        //saving image...
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.isSaved = true
        
        print("saved Successfully")
        
        return image
    }
}

//setting view for preview..
struct CameraPreview : UIViewRepresentable {
    
    
    @ObservedObject var camera : CameraModel
    
    func makeUIView(context: Context) -> some UIView {
        let view  = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        //your own property
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        //starting session
        camera.session.startRunning()
        
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //
    }
}


// photo picker
struct PhotoPicker: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    @Binding var pickerResult: UIImage
    @Binding var isPresented: Bool
    
  func makeUIViewController(context: Context) -> PHPickerViewController {
    let controller = PHPickerViewController(configuration: configuration)
    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  // Use a Coordinator to act as your PHPickerViewControllerDelegate
  class Coordinator: PHPickerViewControllerDelegate {
    private let parent: PhotoPicker

    init(_ parent: PhotoPicker) {
      self.parent = parent
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print(results)
        for image in results {
            if image.itemProvider.canLoadObject(ofClass: UIImage.self)  {
                image.itemProvider.loadObject(ofClass: UIImage.self) { (newImage, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.parent.pickerResult = newImage as! UIImage
                    }
                }
            } else {
                print("Loaded Assest is not a Image")
            }
        }
        parent.isPresented = false // Set isPresented to false because picking has finished.
    }
  }
}



