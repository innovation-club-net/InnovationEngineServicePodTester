//
//  ContentView.swift
//  PodTester
//
//  Created by Fred on 23.12.22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = InnovationEngineViewModel()
    @State var environment: String = "dev"
    @State var timeout: String = "500"
    @State var clientId: String = String(Int(Date().timeIntervalSince1970 * 1000))
    @State var resultDescription: String = ""
    @State var experimentView: ExperimentView?

    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text(viewModel.loaderServer ?? "")
                TextField("Environment", text: $environment)
                TextField("Timeout", text: $timeout)
                TextField("ScreenId", text: $viewModel.screenId)
                Text(clientId)
                Button("Restart") {
                    restart()
                }
                Text(resultDescription)
            }
            if let experimentView = experimentView {
                experimentView
            }
        }
        .padding()
        .onChange(of: environment) { newEnvironment in
            viewModel.configureEnvironment(newEnvironment)
        }
        .onChange(of: timeout) { newTimout in
            viewModel.configureTimeout(newTimout)
        }
        .onAppear() {
            // typically set once at the start of the app
            viewModel.configureEnvironment(environment)
            viewModel.configureTimeout(timeout)
            
            // varies with each screen/view of the app
            viewModel.screenId = "dashboard"
            
            // perform a first initial request
            restart()
        }
    }
    
    func restart() {
        clientId = String(Int(Date().timeIntervalSince1970 * 1000))
        viewModel.configureClientId(clientId)
        viewModel.getExperiments() { getExperimentsResult in
            switch getExperimentsResult {
            case .failure(let error):
                // handle the error
                print("\(error)")
                resultDescription = "\(error.localizedDescription)"

            case .success(let experiments):
                // This example only considers the first entry of the array of Experiments
                guard let experiment = experiments[0] else {
                    print("No experiment returned")
//                    DispatchQueue.main.async {
//                        self.viewModel.setError("No experiment returned")
//                    }
                    return
                }
                // start the experiment
                print("experiments[0] \(experiment)")
//                self.startExperiment(experiment)
                experimentView = ExperimentView(experiment: experiment) { startExperimentResult in
                    switch startExperimentResult {
                    case .failure(let error):
                        // handle the error
                        resultDescription = "\(error.localizedDescription)"

                    case .success(let event):
                        // handle the event
                        print(event.experimentId!)
                        print(event.treatmentUuid!)
                        print(event.interaction!)
                        resultDescription = "\(event.interaction ?? "?")"
                    }

                    experimentView = nil
                }
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
