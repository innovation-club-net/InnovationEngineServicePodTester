//
//  InnovationEngineViewModel.swift
//  PodTester
//
//  Created by Fred on 23.12.22.
//

import Foundation
import InnovationEngineService

class InnovationEngineViewModel: ObservableObject {
    
    @Published var screenId: String = ""

    var innovationEngine: InnovationEngine
    
    private var experimentId: String?
    private var treatmentUuid: String?

    init() {
        innovationEngine = InnovationEngine.shared
        
        let loaderServer = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_LOADER_SERVER") as? String ?? ""
        innovationEngine.configLoaderServer = !loaderServer.isEmpty ? loaderServer : "https://your-instance.innovation-club.net"
        
        let environment = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_ENVIRONMENT") as? String ?? ""
        innovationEngine.configEnvironment = !environment.isEmpty ? environment : "dev"
        
        let timeout = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_TIMEOUT") as? String ?? ""
        innovationEngine.configTimeout = !timeout.isEmpty ? Int(timeout) ?? 500 : 500
        
        // optional experiment ID and treatment UUID (during development phase only)
        experimentId = Bundle.main.object(forInfoDictionaryKey: "FORCE_EXPERIMENT_ID") as? String
        treatmentUuid = Bundle.main.object(forInfoDictionaryKey: "FORCE_TREATMENT_UUID") as? String
        
        // Setup specific fonts to be used:
        
        // The first font added is used as the default one for the <body> element of the Experiments' HTML.
        // Using "Segoe Print" here to highlight the purpose of this configuration.
        // You would typically use the same font face as in your application.
        innovationEngine.addFont(familyName: "Segoe Print",
                                        fileContent: readBytes(for: "segoepr"))

        // Further fonts can be referred to as `font-family` CSS properties in the Experiments' HTML.
        innovationEngine.addFont(familyName: "Mulish",
                                        fileContent: readBytes(for: "Mulish-Regular"))
        // When specifying different styles or weights, you can use the same familyName.
        innovationEngine.addFont(familyName: "Mulish",
                                        fileContent: readBytes(for: "Mulish-Italic"),
                                        descriptors: ["style": "italic"])
    }
    
    
    ///
    ///
    private func readBytes(for fontName: String) -> [UInt8] {
        var bytes = [UInt8]()
        if let filePath = Bundle.main.url(forResource: fontName, withExtension: "woff")?.path, let data = NSData(contentsOfFile: filePath) {
            var buffer: [UInt8] = Array(repeating: 0, count: data.length)
            data.getBytes(&buffer, length: data.length)
            bytes = buffer
        }
        return bytes
    }
    
    
    ///
    ///
    func configureClientId(_ clientId: String) {
        innovationEngine.configClientId = clientId
    }
    
    
    ///
    ///
    func getExperiments(completion: @escaping (Result<[Experiment?], Error>) -> Void) {
        
        // multi screenId call
        innovationEngine.getExperiments(screenIds: [screenId], experimentId: experimentId, treatmentUuid: treatmentUuid) { result in
            completion(result)
        }
        
        // single screenId call
//        innovationEngine.getExperiment(screenId: screenId) { result in
//            print(result)
//            switch result {
//            case .success(let experiment):
//                print("experiment \(experiment)")
//            case .failure(let error):
//                print("error: \(error)")
//            }
//            completion(Result(catching: {
//                switch result {
//                case .success(let experiment):
//                    return [experiment]
//                case .failure(let error):
//                    throw error
//                }
//            }))
//        }
    }
    
    
    ///
    ///
    static func getMessageForError(_ error: Error) -> String {
        switch error as? RequestError {
        case .error(let error):
            return error.localizedDescription
        case .parsing:
            return "InnovationEngine parsing failed"
        case .webPageEmpty:
            return "InnovationEngine web page is empty"
        case .none:
            fatalError("InnovationEngine request failed \n error in wrong format")
        }
    }

}
