//
//  ContentView.swift
//  PodTester
//
//  Created by Fred on 23.12.22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = InnovationEngineViewModel()
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
                        VStack(alignment: .leading, spacing: 5) {
                            Text("configLoaderServer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(viewModel.loaderServer ?? "")
                                .padding(5)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("configTimeout")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(timeout)
                                .padding(5)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("configEnvironment")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(environment)
                                .padding(5)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Screen ID passed to getExperiments()")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("ScreenId", text: $viewModel.screenId)
                                .padding(10)
                                .background(.background)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("configClientId (*)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(clientId)
                                .padding(5)
                            Text("(*) newly generated on each request for testing purposes")
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        Button("GetExperiment") {
                            getExperiment(scrollViewProxy: scrollViewProxy)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Result")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(resultDescription)
                                .padding(5)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .id(bottomID)
                        Spacer()
                    }
                    .padding()
                }
                .task {
                    timeout = String(describing: viewModel.innovationEngine.configTimeout)
                    environment = viewModel.innovationEngine.configEnvironment ?? ""

                    // varies with each screen/view of the app
                    viewModel.screenId = "dashboard"
                    
                    // perform a first initial request
                    getExperiment(scrollViewProxy: scrollViewProxy)
                }
            }
            
            // Cover the config screen with the experiment's WebView
            if let experimentView = experimentView {
                experimentView
            }
        }
        .background(Color(UIColor.secondarySystemBackground))

    }
    
    func getExperiment(scrollViewProxy: ScrollViewProxy) {
        resultDescription = ""
        clientId = String(Int(Date().timeIntervalSince1970 * 1000))
        viewModel.configureClientId(clientId)
        viewModel.getExperiments() { getExperimentsResult in
            switch getExperimentsResult {
            case .failure(let error):
                // handle the error
                resultDescription = InnovationEngineViewModel.getMessageForError(error)
                print(resultDescription)
                scrollViewProxy.scrollTo(bottomID)

            case .success(let experiments):
                // This example only considers the first entry of the array of Experiments
                guard let experiment = experiments[0] else {
                    print("No experiment returned")
                    resultDescription = "No experiment returned"
                    scrollViewProxy.scrollTo(bottomID)
                    return
                }
                print("experiments[0] \(experiment)")

                // start the experiment in a view
                experimentView = ExperimentView(experiment: experiment) { startExperimentResult in
                    switch startExperimentResult {
                    case .failure(let error):
                        // handle the error
                        resultDescription = "\(error.localizedDescription)"
                        scrollViewProxy.scrollTo(bottomID)

                    case .success(let event):
                        // handle the event
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




