import UIKit
import Flutter
import OpenTok

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate , OTPublisherKitDelegate, OTSubscriberKitDelegate, OTSessionDelegate{
    func sessionDidDisconnect(_ session: OTSession) {
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
    }
    
    
    func sessionDidConnect(_ session: OTSession) {
      doPublish()
    }
    
    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")}
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let screenShareChannel = FlutterMethodChannel(name: "screenShare",
                                              binaryMessenger: controller.binaryMessenger)
    screenShareChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
        guard call.method == "StartSharing" else {
           result(FlutterMethodNotImplemented)
           return
         }// Handle battery messages.
        self?.doConnect()
    })


    GeneratedPluginRegistrant.register(with: self)
//    weak var registrar = self.registrar(forPlugin: "plugin-name")

//           let factory = FLNativeViewFactory(messenger: registrar!.messenger())
//           self.registrar(forPlugin: "<plugin-name>")!.register(
//               factory,
//               withId: "iosView")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    var kApiKey = "47043564"
    // Replace with your generated session ID
    var kSessionId = "1_MX40NzA0MzU2NH5-MTYwODY0ODc2MjM5OH43dUpMblQvSTFaTGc1K3NxM2VRd3FmRXl-fg"
    // Replace with your generated token
    var kToken = "T1==cGFydG5lcl9pZD00NzA0MzU2NCZzaWc9M2E4ZjRiYjU5MWIzOWU5MzY1NTgwYjExNWU1NjczZTJjYjlmZWE2MTpzZXNzaW9uX2lkPTFfTVg0ME56QTBNelUyTkg1LU1UWXdPRFkwT0RjMk1qTTVPSDQzZFVwTWJsUXZTVEZhVEdjMUszTnhNMlZSZDNGbVJYbC1mZyZjcmVhdGVfdGltZT0xNjA4NjQ4Nzc4Jm5vbmNlPTAuNzEzNTM0NDQ3MzE0ODM3MSZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjExMjQwNzc3JmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
     lazy var session: OTSession = {
          return OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
      }()
    
  var publisher: OTPublisher?
  var subscriber: OTSubscriber?
  var capturer: ScreenCapturer?
    
    private func doConnect() {
        var error: OTError?
        defer {
            process(error: error)
        }
        session.connect(withToken: kToken, error: &error)
    }
    
    fileprivate func doPublish() {
         var error: OTError? = nil
         defer {
             process(error: error)
         }
         let settings = OTPublisherSettings()
         settings.name = UIDevice.current.name
         publisher = OTPublisher(delegate: self, settings: settings)
         publisher?.videoType = .screen
         publisher?.audioFallbackEnabled = false
         
         capturer = ScreenCapturer()
         publisher?.videoCapture = capturer
         
        session.publish(publisher!, error: &error)
     }
     
//     fileprivate func doSubscribe(_ stream: OTStream) {
//         var error: OTError?
//         defer {
//             process(error: error)
//         }
//         subscriber = OTSubscriber(stream: stream, delegate: self)
//
//        session.subscribe(subscriber!, error: &error)
//     }
     
     fileprivate func process(error err: OTError?) {
         if let e = err {
             showAlert(errorStr: e.localizedDescription)
         }
     }
     
     fileprivate func showAlert(errorStr err: String) {
         DispatchQueue.main.async {
             let controller = UIAlertController(title: "Error", message: err, preferredStyle: .alert)
             controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
         
   
                controller.view.frame = (self.window!.frame)
                self.window!.addSubview(controller.view)
                self.window!.bringSubviewToFront(controller.view)
            
//             self.present(controller, animated: true, completion: nil)
         }
     }
}

//class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
//    private var messenger: FlutterBinaryMessenger
//    // Replace with your OpenTok API key
//
//    init(messenger: FlutterBinaryMessenger) {
//        self.messenger = messenger
//        super.init()
//    }
//
//    func create(
//        withFrame frame: CGRect,
//        viewIdentifier viewId: Int64,
//        arguments args: Any?
//    ) -> FlutterPlatformView {
//        return FLNativeView(
//            frame: frame,
//            viewIdentifier: viewId,
//            arguments: args,
//            binaryMessenger: messenger)
//    }
//}
//
//class FLNativeView: NSObject, FlutterPlatformView, OTSessionDelegate, OTPublisherKitDelegate {
//    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
//
//    }
//
//    func sessionDidConnect(_ session: OTSession) {
//        var error: OTError?
//        print("The client connected to the OpenTok session.")
//        let settings = OTPublisherSettings()
//        settings.name = UIDevice.current.name
//        guard let publisher = OTPublisher(delegate: self, settings: settings) else {
//            return
//        }
//        publisher.publishAudio = true
//        publisher.publishVideo = true
//        publisher.videoType = .screen
//        publisher.audioFallbackEnabled = false
//
//        session.publish(publisher, error: &error)
//        guard error == nil else {
//            print(error!)
//            return
//        }
//
//        guard let publisherView = publisher.view else{
//            return
//        }
//        publisherView.frame = view().frame
//        view().insertSubview(publisherView,at: 0)
//    }
//
//    func sessionDidDisconnect(_ session: OTSession) {
//
//    }
//
//    func session(_ session: OTSession, didFailWithError error: OTError) {
//         print("errorSession", error)
//    }
//
//    func session(_ session: OTSession, streamCreated stream: OTStream) {
//
//    }
//
//    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
//
//    }
//
//    private var _view: UIView
//
//
//    init(
//        frame: CGRect,
//        viewIdentifier viewId: Int64,
//        arguments args: Any?,
//        binaryMessenger messenger: FlutterBinaryMessenger?
//    ) {
//        _view = UIView()
//        super.init()
//        // iOS views can be created here
//        createNativeView(view: _view)
////        self.connectToAnOpenTokSession()
//    }
//
//    func view() -> UIView {
//        return _view
//    }
//
//    func createNativeView(view _view: UIView){
//        _view.backgroundColor = UIColor.blue
//    }
//
//    func connectToAnOpenTokSession() {
//        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
//        var error: OTError?
//        session?.connect(withToken: kToken, error: &error)
//        if error != nil {
//            print(error!)
//        }
//    }
//}
