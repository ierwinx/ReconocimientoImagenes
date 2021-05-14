import UIKit
import Vision
import CoreML

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var texto: UILabel!
    
    // MARK: Properties
    private var imagePicker: UIImagePickerController?
    
    // MARK: Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()
        texto.text = "cargando ..."
        detectarTexto()
    }
    
    // MARK: MachineLearning
    private func detectarTexto() -> Void {
        guard let modelo = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            return
        }
        let peticion = VNCoreMLRequest(model: modelo) { (request, error) in
            guard let resultado = request.results as? [VNClassificationObservation], let primeResultado = resultado.first else {
                return
            }
            DispatchQueue.main.async {
                self.texto.text = "\(primeResultado.identifier) \(primeResultado.confidence*100)%"
            }
        }
        guard let imagen = CIImage(image: self.imagen.image!) else {
            return
        }
        let handler = VNImageRequestHandler(ciImage: imagen)
        DispatchQueue.global().async {
            do {
                try handler.perform([peticion])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: Actions
    @IBAction func carreteAction(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .photoLibrary
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagenPicker = imagePicker else {
            return
        }
        
        present(imagenPicker, animated: true, completion: nil)
    }
    
    @IBAction func fotoAction(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagenPicker = imagePicker else {
            return
        }
        
        present(imagenPicker, animated: true, completion: nil)
    }
    
}

// MARK: Extencion
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: ImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        //cerrar camara
        picker.dismiss(animated: true, completion: nil)
        
        // add image
        if info.keys.contains(.originalImage) {
            self.imagen.image = info[.originalImage] as? UIImage
        }
        
        self.detectarTexto()
        
    }
    
}
