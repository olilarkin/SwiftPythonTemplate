import Cocoa
import PythonKit
import SwiftUI

class ViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let sys = Python.import("sys")
    // print("Python Path: \(sys.path)")
    let app = Python.import("app")
    
    // Create and add SwiftUI view
    let swiftUIView = NSHostingView(rootView: ContentView(pythonApp: app))
    swiftUIView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(swiftUIView)
    
    NSLayoutConstraint.activate([
      swiftUIView.topAnchor.constraint(equalTo: view.topAnchor),
      swiftUIView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      swiftUIView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      swiftUIView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  override func viewWillAppear() {
  }

  override var representedObject: Any? {
    didSet {
    }
  }

}

struct ContentView: View {
  let pythonApp: PythonObject
  
  var body: some View {
    Button("Run Python Function") {
      runPythonFunction()
    }
    .padding()
  }
  
  func runPythonFunction() {
    pythonApp.run()
  }
}
