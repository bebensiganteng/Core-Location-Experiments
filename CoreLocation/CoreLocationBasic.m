//
//  CoreLocationBasic.m
//  CoreLocation
//
//  Created by Rachmad Hidayat on 7/17/14.
//  Copyright (c) 2014 Rahmat Hidayat. All rights reserved.
//

#import "CoreLocationBasic.h"

@implementation CoreLocationBasic

@synthesize locationManager;

//1: check Bluetooth
- (void)setBluetooth
{
    // Blue tooth test
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                queue:nil
                                                              options:nil];
}

// Only call once
- (void) setupLocationManager
{
    // Initialization
    timeStamp       = [NSDate dateWithTimeIntervalSince1970:0];
    isGeoFencing    = NO;
    
    [self resetDispatcher];
    
    // Location Manager
    locationManager                 = [[CLLocationManager alloc] init];
    locationManager.delegate        = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter  = kCLDistanceFilterNone;
    locationManager.activityType    = CLActivityTypeFitness;
    
    // iOS8.0 directives
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    
    if (![self isSupported]) {
        if ([self isConformedToProtocol]) {
            
            isError = @"CoreLocation is not supported";
            
        }
    }
}

- (void)resetDispatcher
{
    
    [self setValue:@"" forKey:@"isError"];
    [self setValue:@"..." forKey:@"beaconDistance"];
    [self setValue:@"..." forKey:@"sTimeStamp"];
    [self setValue:@"..." forKey:@"sAccuracy"];
    [self setValue:@"..." forKey:@"sRSSI"];
    [self setValue:@"..." forKey:@"sMajor"];
    [self setValue:@"..." forKey:@"sMinor"];
    [self setValue:@"..." forKey:@"sState"];

}

#pragma mark - Peripheral Manager

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
    BOOL isBlueTooth = NO;
    NSString *msg;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            isBlueTooth = YES;
            break;
        case CBPeripheralManagerStatePoweredOff:
            msg = @"Bluetooth is currently powered off";
            break;
        case CBPeripheralManagerStateUnknown:
            msg = @"Bluetooth is currently powered off";
            break;
        case CBPeripheralManagerStateUnsupported:
            msg = @"The platform doesn't support the Bluetooth low energy peripheral/server role.";
            break;
        case CBPeripheralManagerStateUnauthorized:
            msg = @"The app is not authorized to use the Bluetooth low energy peripheral/server role.";
        case CBPeripheralManagerStateResetting:
            msg = @"The connection with the system service was momentarily lost; an update is imminent.";
            break;
    }
    
    if ([self isConformedToProtocol] && !isBlueTooth) {
        
        isError = msg;
        [self.delegate locationError:isError];
        
    }
}



#pragma mark - CoreLocation Utils

- (BOOL) isSupported
{
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"Beacon Tracking Unavailable");
    }
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location Services Unavailable");
        
    } else {
        
        if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            NSLog(@"GeoFence Monitoring Unavailable");
            
        } else {
            
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
                
                NSLog(@"Location Tracking Unavailable");
            } else {
                
                // We have the services we need to get started
                
                return YES;
            }
        }
    }
    
    return NO;
}


#pragma mark - Utils

+ (float)getVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}


- (BOOL)isConformedToProtocol
{
    if ([self.delegate conformsToProtocol:@protocol(CoreLocationManagerDelegate)]) {
        return YES;
    }
    
    return NO;
}

@end
