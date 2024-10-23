import Cocoa
import Python
import PythonKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  override init() {
        super.init()
        setupPython()
    }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
  }

  func setupPython() {
    let resourcePath = Bundle.main.resourcePath!
    let pythonHome = "\(resourcePath)/python"
    let stdLibPath = "\(pythonHome)/lib/python3.11"
    let libDynloadPath = "\(pythonHome)/lib/python3.11/lib-dynload"
    let appPackagesPath = "\(resourcePath)/app_packages"
    let appPath = "\(resourcePath)/app"
    
    // Initialize Python configuration
    var preconfig = PyPreConfig()
    var config = PyConfig()
    
    PyPreConfig_InitIsolatedConfig(&preconfig)
    PyConfig_InitIsolatedConfig(&config)
    
    // Configure the Python interpreter
    preconfig.utf8_mode = 1
    config.buffered_stdio = 0
    config.write_bytecode = 0
    config.module_search_paths_set = 1
    
    // Pre-initialize Python runtime
    var status = Py_PreInitialize(&preconfig)
    if (PyStatus_Exception(status) != 0) {
      fatalError("Unable to pre-initialize Python interpreter: \(String(cString: status.err_msg!))")
    }
    
    // Set Python home
    if let wtmp_str = Py_DecodeLocale(pythonHome, nil) {
      var localHome = config.home
      status = PyConfig_SetString(&config, &localHome, wtmp_str)
      if (PyStatus_Exception(status) != 0) {
        fatalError("Unable to set PYTHONHOME: \(String(cString: status.err_msg!))")
      }
      config.home = localHome
      PyMem_RawFree(wtmp_str)
    }
    
    // Set module search paths
    for path in [stdLibPath, libDynloadPath, appPackagesPath, appPath] {
//      print("Adding to Python path: \(path)")
      if let wtmp_str = Py_DecodeLocale(path, nil) {
        status = PyWideStringList_Append(&config.module_search_paths, wtmp_str)
        if (PyStatus_Exception(status) != 0) {
          fatalError("Unable to set path: \(String(cString: status.err_msg!))")
        }
        PyMem_RawFree(wtmp_str)
      }
    }
    
    // Read the site config
    status = PyConfig_Read(&config)
    if (PyStatus_Exception(status) != 0) {
      fatalError("Unable to read site config: \(String(cString: status.err_msg!))")
    }
    
    // Initialize Python
    status = Py_InitializeFromConfig(&config)
    if (PyStatus_Exception(status) != 0) {
      fatalError("Unable to initialize Python interpreter: \(String(cString: status.err_msg!))")
    }
    
    PyConfig_Clear(&config)
    
    // At this point, Python is initialized and ready to use
    // You can now run Python code, import modules, etc.
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    Py_Finalize()
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
