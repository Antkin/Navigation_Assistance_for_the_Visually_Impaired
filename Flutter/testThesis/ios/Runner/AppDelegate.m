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
            if (self.motionManager == nil){
                //printf("Initializing motion manager in iOS Code!\n");
                self.motionManager = [[CMMotionManager alloc] init];
            }
            
            if (self.motionManager.isDeviceMotionAvailable) {
                if (self.motionManager.isDeviceMotionActive){
                    //printf("Inside active device motion ios code!.\n");
                    yaw = self.motionManager.deviceMotion.attitude.yaw;
                    yaw = (yaw * 180.0)/3.1415;
                    result(@(yaw));
                }
                else{
                    //printf("Inside sensor setup ios code\n");
                    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60;
                    self.motionManager.showsDeviceMovementDisplay = false;
                    //self.motionManager.startDeviceMotionUpdates;
                    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame: CMAttitudeReferenceFrameXArbitraryZVertical];
                    //Returns yaw in radians, convert to deg
                    yaw = self.motionManager.deviceMotion.attitude.yaw;
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
//Returns updated yaw measurements once sensors are initialized
- (double)getBatteryLevel {
    //printf("inside get battery level function ios code\n");
    if (self.motionManager.isDeviceMotionActive){
       // printf("inside getbatterylevel activedevicemotion ios code\n");
        yaw = self.motionManager.deviceMotion.attitude.yaw;
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
