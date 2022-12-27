//
//  ContentView.swift
//  PodTester
//
//  Created by Fred on 23.12.22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = InnovationEngineViewModel()
    @State var loaderServer: String = ""
    @State var environment: String = ""
    @State var timeout: String = ""
    @State var clientId: String = String(Int(Date().timeIntervalSince1970 * 1000))
    @State var resultDescription: String = ""
    @State var experimentView: ExperimentView?

    @Namespace var bottomID
    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        CompactFormItemView(header: "configLoaderServer", text: $loaderServer)
                        CompactFormItemView(header: "configTimeout", text: $timeout)
                        CompactFormItemView(header: "configEnvironment", text: $environment)
                        CompactFormItemView(header: "Screen ID passed to getExperiments()", text: $viewModel.screenId, isEditable: true)
                        CompactFormItemView(header: "configClientId (*)", text: $clientId, footer: "(*) newly generated on each request for testing purposes")

                        Button("GetExperiment") {
                            getExperiment(scrollViewProxy: scrollViewProxy)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Result")
                                .font(.custom("Mulish-Regular", size: 15, relativeTo: .subheadline))
                                .foregroundColor(.secondary)
                            Text(resultDescription)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .id(bottomID)
                        Spacer()
                    }
                    .padding()
                }
                .task {
                    // initialisation values the Innovation Engine
                    loaderServer = viewModel.innovationEngine.configLoaderServer ?? ""
                    environment = viewModel.innovationEngine.configEnvironment ?? ""
                    timeout = String(describing: viewModel.innovationEngine.configTimeout)

                    // Each call to getExperiments expects at least one screen ID
                    let sampleScreenId = Bundle.main.object(forInfoDictionaryKey: "SAMPLE_SCREEN_ID") as? String ?? ""
                    viewModel.screenId = !sampleScreenId.isEmpty ? sampleScreenId : "demo"
                    
                    // perform a first initial request
                    getExperiment(scrollViewProxy: scrollViewProxy)
                }
            }
            
            // Using the ZStack, cover the config screen with the experiment's WebView
            if let experimentView = experimentView {
                experimentView
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .font(.custom("Mulish-Regular", size: 17))
    }
    
    
    ///
    ///
    func getExperiment(scrollViewProxy: ScrollViewProxy) {
        resultDescription = ""
        
        // Generate new clientId to simulate a request for a different user
        // Setting the configClientId property of the Innovation Engine is typically
        // only performed once as soon as some ID of the user us available
        clientId = String(Int(Date().timeIntervalSince1970 * 1000))
        viewModel.configureClientId(clientId)
        
        // Call the Innovation Engine to receive an Experiment for the given
        // - environment
        // - screen ID
        viewModel.getExperiments() { getExperimentsResult in
            switch getExperimentsResult {
            case .failure(let error):
                // handle the error
                resultDescription = InnovationEngineViewModel.getMessageForError(error)
                print(resultDescription)
                scrollViewProxy.scrollTo(bottomID)

            case .success(let experiments):
                // This example app only considers the first entry of the array of Experiments
                guard let experiment = experiments[0] else {
                    print("No experiment returned")
                    resultDescription = "No experiment returned"
                    scrollViewProxy.scrollTo(bottomID)
                    return
                }
                print("experiments[0] \(experiment)")

                // Start the experiment in a view
                experimentView = ExperimentView(experiment: experiment) { startExperimentResult in
                    switch startExperimentResult {
                    case .failure(let error):
                        // Handle the error
                        resultDescription = "\(error.localizedDescription)"
                        scrollViewProxy.scrollTo(bottomID)

                    case .success(let event):
                        // Handle the event
                        print(event.experimentId!)
                        print(event.treatmentUuid!)
                        print(event.interaction!)
                        resultDescription = "\(event.interaction ?? "?")"
                        scrollViewProxy.scrollTo(bottomID)
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




