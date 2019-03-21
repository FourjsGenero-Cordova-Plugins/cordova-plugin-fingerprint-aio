#import <Cordova/CDVPlugin.h>

@import LocalAuthentication;
@interface Fingerprint :CDVPlugin
@end
@implementation Fingerprint

-(void)isAvailable:(CDVInvokedUrlCommand*)command
{
  LAContext *ctx = [[LAContext alloc] init];
  NSString* biometryType = @"finger";
  NSError* error=nil;
  bool available=[ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
  if (@available(iOS 11.2, *)) {
    if(error != nil && error.code == LAErrorBiometryNotAvailable){
      biometryType = @"none";
    } else {
      if (ctx.biometryType == LABiometryTypeFaceID) {
        biometryType = @"face";
      } else if (ctx.biometryType == LABiometryTypeNone) {
        biometryType = @"none";
      }
    }
  } else if (!available) {
    biometryType = @"none";
  }
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:biometryType] callbackId:command.callbackId];
}

-(void)authenticate:(CDVInvokedUrlCommand*)command 
{
  NSString *callbackId = command.callbackId;
  LAContext *ctx = [[LAContext alloc] init];
  NSError* error=nil;
  if (![ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription] callbackId:callbackId];
    return;
  }
  NSString* reason = @"Authentication";
  NSDictionary *data = [command.arguments objectAtIndex:0];
  NSString* localizedFallbackTitle = data[@"localizedFallbackTitle"];
  if (localizedFallbackTitle != nil ) {
     ctx.localizedFallbackTitle = localizedFallbackTitle;
  }
  LAPolicy policy=LAPolicyDeviceOwnerAuthentication;
  NSNumber* disableBackup = data[@"disableBackup"];
  if (disableBackup!=nil) {
    if (disableBackup.boolValue) {
      ctx.localizedFallbackTitle = @"";
      policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    }
  }
  NSString* localizedReason = data[@"localizedReason"];
  if (localizedReason!=nil) {
    reason = localizedReason;
  } else {
    NSString* clientId=data[@"clientId"];
    if (clientId!=nil) {
      reason=clientId;
    }
  }
  [ctx evaluatePolicy:policy localizedReason:reason reply:^(BOOL ok, NSError *error) {
    CDVPluginResult* result;
    if (ok) {
      result=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Success"];
    } else {
      // invoked when the scan failed 3 times in a row, the cancel button was pressed, or the 'enter password' button was pressed
     result=[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }];
}
@end
