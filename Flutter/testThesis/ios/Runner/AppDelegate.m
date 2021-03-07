#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel methodChannelWithName:@"samples.flutter.dev/battery" binaryMessenger:controller.binaryMessenger];
    __weak typeof(self) weakSelf = self;
    [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result){

        //TODO IMPLEMENT HERE
        if ([@"getBatteryLevel" isEqualToString:call.method]) {
            int batteryLevel = [weakSelf getBatteryLevel];
            self.motion = [[CMMotionManager alloc]init];
            
            if (self.motion.isDeviceMotionAvailable) {
                self.motion.deviceMotionUpdateInterval = 1.0 / 60;
                self.motion.showsDeviceMovementDisplay = true;
                self.motion.startDeviceMotionUpdates;

                //CMDeviceMotion *data = motion.deviceMotion;
                //result(@(data.rotationRate.x));
                result([FlutterError errorWithCode:@"TEST"
                                           message:@"Sensors have been made available." details:nil]);
            } else {
                result([FlutterError errorWithCode:@"TEST"
                                           message:@"Sensors are unavailable." details:nil]);
            }
            
            if (batteryLevel == -1) {
                result([FlutterError errorWithCode:@"UNAVAILABLE"
                                           message:@"Battery info unavailable" details:nil]);
            } else {
                //result(@(batteryLevel));
                //The line below can be uncommented to ensure that this code is being succesfully called during execution
                result([FlutterError errorWithCode:@"TEST"
                                           message:@"Flutter is successfully calling platform code." details:nil]);
                 
            }
        } else {
                result(FlutterMethodNotImplemented);
            }
    }];
    
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (int)getBatteryLevel {
    UIDevice* device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    if (device.batteryState == UIDeviceBatteryStateUnknown){
        return -1;
    } else{
        return (int)(device.batteryLevel * 100);
    }
}
@end
