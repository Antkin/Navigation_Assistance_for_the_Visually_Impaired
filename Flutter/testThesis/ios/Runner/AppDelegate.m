#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

double yaw = 0.0;

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
                if (self.motion.isDeviceMotionActive){
                    yaw = self.motion.deviceMotion.attitude.yaw;
                    yaw = (yaw * 180.0)/3.1415;
                    result(@(yaw));
                }
                else{
                    self.motion.deviceMotionUpdateInterval = 1.0 / 60;
                    self.motion.showsDeviceMovementDisplay = false;
                    self.motion.startDeviceMotionUpdates;
                    
                    yaw = self.motion.deviceMotion.attitude.yaw;
                    yaw = (yaw * 180.0)/3.1415;
                    //CMDeviceMotion *data = motion.deviceMotion;
                    //result(@(data.rotationRate.x));
                    result(@(yaw));
                }
            } else {
                result([FlutterError errorWithCode:@"TEST"
                                           message:@"Sensors are unavailable." details:nil]);
            }
        } else {
                result(FlutterMethodNotImplemented);
            }
    }];
    
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (double)getBatteryLevel {
    if (self.motion.isDeviceMotionActive){
        yaw = self.motion.deviceMotion.attitude.yaw;
        yaw = (yaw * 180.0)/3.1415;
        return yaw;
    }
    else{
        return -1.0;
    }
    
    /*
    UIDevice* device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    if (device.batteryState == UIDeviceBatteryStateUnknown){
        return -1;
    } else{
        return (int)(device.batteryLevel * 100);
    }
     */
}
@end
