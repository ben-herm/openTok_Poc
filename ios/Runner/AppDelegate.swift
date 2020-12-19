import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
        weak var registrar = self.registrar(forPlugin: "plugin-name")

           let factory = FLNativeViewFactory(messenger: registrar!.messenger())
           self.registrar(forPlugin: "<plugin-name>")!.register(
               factory,
               withId: "iosView")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    // Replace with your OpenTok API key

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class FLNativeView: NSObject, FlutterPlatformView, OTSessionDelegate, OTPublisherKitDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
    
    }
    
    func sessionDidConnect(_ session: OTSession) {
        var error: OTError?
        print("The client connected to the OpenTok session.")
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        guard let publisher = OTPublisher(delegate: self, settings: settings) else {
            return
        }
        publisher.publishAudio = true
        publisher.publishVideo = true
        publisher.videoType = .camera
        publisher.audioFallbackEnabled = false
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let publisherView = publisher.view else{
            return
        }
        publisherView.frame = view().frame
        view().insertSubview(publisherView,at: 0)
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
            
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        
    }
    
    private var _view: UIView
    var kApiKey = "47043564"
    // Replace with your generated session ID
    var kSessionId = "2_MX40NzA0MzU2NH5-MTYwNzk0OTIxMTAyMX5TVlpSb3lYQ21hTGllRkRtNFJIanFqeXl-fg"
    // Replace with your generated token
    var kToken = "T1==cGFydG5lcl9pZD00NzA0MzU2NCZzaWc9NDdlNTRlNGMyNWMzYzA0MDllNGI0NDkxOTllNWJkNDQ0Nzk0Nzc1MTpzZXNzaW9uX2lkPTJfTVg0ME56QTBNelUyTkg1LU1UWXdOemswT1RJeE1UQXlNWDVUVmxwU2IzbFlRMjFoVEdsbFJrUnRORkpJYW5GcWVYbC1mZyZjcmVhdGVfdGltZT0xNjA3OTQ5MjU2Jm5vbmNlPTAuMjEzNzA3NjA4NDcyODMzMzImcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTYxMDU0MTI1NSZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ=="
    var session: OTSession?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        // iOS views can be created here
        createNativeView(view: _view)
        self.connectToAnOpenTokSession()
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView){
        _view.backgroundColor = UIColor.blue
    }
    
    func connectToAnOpenTokSession() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
        var error: OTError?
        session?.connect(withToken: kToken, error: &error)
        if error != nil {
            print(error!)
        }
    }
}

