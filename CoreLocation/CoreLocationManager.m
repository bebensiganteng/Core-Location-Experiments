//
//  CoreLocationManager.m
//  CoreLocation
//
//  Created by Rahmat Hidayat on 2014/07/14.
//  Copyright (c) 2014年 Rahmat Hidayat. All rights reserved.
//


#import "CoreLocationManager.h"

@implementation CoreLocationManager

@synthesize locationManager;

+ (CoreLocationManager *) sharedLocationManager
{
    // https://www.mikeash.com/pyblog/friday-qa-2009-08-28-intro-to-grand-central-dispatch-part-i-basics-and-dispatch-queues.html
    static dispatch_once_t onceToken;
    static CoreLocationManager *sharedLocationManager = nil;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[super alloc] initInstance];
    });

    return sharedLocationManager;
}

- (CoreLocationManager *) initInstance
{
    self = [super init];
    
    if (self != nil) {

        [self setupLocationManager];
    }
    
    return self;
}

- (void) setupLocationManager
{
    
    timeStamp                       = [NSDate dateWithTimeIntervalSince1970:0];
    
    isGeoFencing                    = NO;
    
    locationManager                 = [[CLLocationManager alloc] init];
    locationManager.delegate        = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter  = kCLDistanceFilterNone;
    locationManager.activityType    = CLActivityTypeFitness;
    
    // TODO: Doesn't need both I think
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    
    if (![self isSupported]) {
        NSLog(@"Not Supported");
    }
}

#pragma mark - isSupported

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

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //[self setup];
}

- (void)startUpdatingLocation
{
    [locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    [locationManager stopUpdatingLocation];
}

- (void)stopAll
{
    [self stopUpdatingLocation];
    [self stopMonitoringRegion];
}


#pragma mark - GeoFencing

- (void) enableGeoFence:(CLLocationCoordinate2D)center locationDistance:(CLLocationDistance)radius
{
    
    if (radius > locationManager.maximumRegionMonitoringDistance) {
        radius = locationManager.maximumRegionMonitoringDistance;
    }
    
    isGeoFencing = YES;
    
    // Create the geographic region to be monitored. iOS 8.0
    circularRegion = [[CLCircularRegion alloc]
                      initWithCenter:center
                      radius:radius
                      identifier:@"com.bebensiganteng.geofencing"];
    
    circularRegion.notifyOnEntry    = YES;
    circularRegion.notifyOnExit     = YES;
    
    BOOL monitoringAvailability = [CLLocationManager isMonitoringAvailableForClass:[circularRegion class]];
    
    if( monitoringAvailability ) {
        [locationManager startMonitoringForRegion:circularRegion];
        
    } else {
        
        NSLog(@"[ERROR] monitoring is unavailable");
    }
    
    // TODO: use block code
    // http://www.cocoanetics.com/2014/05/radar-monitoring-clregion-immediately-after-removing-one-fails/
    [self performSelector:@selector(requestState:) withObject:circularRegion afterDelay:1];

}

- (void)requestState:(CLRegion*)region
{
    [self.locationManager requestStateForRegion:circularRegion];
}

#pragma mark - GeoFencing Delegates

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"didStartMonitoringForRegion");
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    CLBeaconRegion *br = (CLBeaconRegion *)region;
    
    NSLog(@"didEnterRegion %@", br.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    CLBeaconRegion *br = (CLBeaconRegion *)region;
    
    NSLog(@"didExitRegion %@", br.identifier);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed monitoring region: %@", error);
}

#pragma mark - Default delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation floor:%@, lat:%f, long:%f", newLocation.floor, newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    NSLog(@"didUpdateToLocation BeaconPosition %f %f", self.beaconPosition.latitude, self.beaconPosition.longitude);
    
    if ([self isConformedToProtocol]) {
        [self.delegate locationUpdateTo:newLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed: %@", error);
}

#pragma mark - iBeacon

- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID identifier:(NSString *)sID
{
    // Create the beacon region to be monitored.
    beaconRegion = [[CLBeaconRegion alloc]
                    initWithProximityUUID:proximityUUID
                    identifier:sID];
    
    beaconRegion.notifyEntryStateOnDisplay  = YES;
    beaconRegion.notifyOnEntry              = YES;
    beaconRegion.notifyOnExit               = YES;
    
    closestBeacon                           = nil;
    beaconDistance                          = @"?";
    sTimeStamp                              = @"?";
    sAccuracy                               = @"?";
    sRSSI                                   = @"?";
    sMajor                                  = @"?";
    sMinor                                  = @"?";
    
    // Register the beacon region with the location manager.
    [self startMonitoringRegion];
}

- (void)startMonitoringRegion
{
    [self stopMonitoringRegion];
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager requestStateForRegion:beaconRegion];
}

- (void)stopMonitoringRegion
{
    //NSLog(@"stopMonitoringRegion: %lu", (unsigned long)[locationManager.monitoredRegions count]);
    
    // ensure everything is cleared
    for (CLRegion *region in [locationManager monitoredRegions]) {
        [locationManager stopMonitoringForRegion:region];
    }
    
    [locationManager stopRangingBeaconsInRegion:beaconRegion];
    
    isGeoFencing = NO;
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //NSLog(@"didRangeBeacon %lu", (unsigned long)beacons.count);
    
    if (beacons.count < 1) {
        return;
    }
    
    NSInteger strongestSignal = -100;
    
    for (CLBeacon *beacon in beacons) {
        
        if (beacon.rssi > strongestSignal && beacon.rssi != 0) {
            closestBeacon = beacon;
        }
        
    }
    
    switch (closestBeacon.proximity) {
        case CLProximityUnknown:
            beaconDistance = @"?";
            break;
        case CLProximityFar:
            beaconDistance = @"Far";
            break;
        case CLProximityNear:
            beaconDistance = @"Near";
            break;
        case CLProximityImmediate:
            beaconDistance = @"Immediate";
            break;
    }
    
    /*
    if (beaconLocation.longitude == 0) {
        
        CLLocationDegrees latitude  = [region.major doubleValue];
        CLLocationDegrees longitude = [region.minor doubleValue];
        beaconLocation = CLLocationCoordinate2DMake(latitude, longitude);

    }*/
    
    //NSLog(@"didRangeBeacon %f, %f",beaconLocation.latitude, beaconLocation.longitude);
    
    NSLog(@"major minor %@, %@",closestBeacon.major,closestBeacon.minor);

    
    [self setValue:beaconDistance forKey:@"beaconDistance"];
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:timeStamp];
    [self setValue:[NSString stringWithFormat:@"%f",interval] forKey:@"sTimeStamp"];
    
    [self setValue:[NSString stringWithFormat:@"%f",closestBeacon.accuracy] forKey:@"sAccuracy"];
    
    [self setValue:[NSString stringWithFormat:@"%ld",(long)closestBeacon.rssi] forKey:@"sRSSI"];
    
    [self setValue:[NSString stringWithFormat:@"%@",closestBeacon.major] forKey:@"sMajor"];
    
    [self setValue:[NSString stringWithFormat:@"%@",closestBeacon.minor] forKey:@"sMinor"];

}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateUnknown:
            NSLog(@"CLRegionStateUnknown");
            
            break;
            
        case CLRegionStateInside:
            NSLog(@"CLRegionStateInside");
            
            if (beaconRegion && !isGeoFencing) {
                [locationManager startRangingBeaconsInRegion:beaconRegion];
            }
            break;
            
        case CLRegionStateOutside:
            NSLog(@"CLRegionStateOutside");
            break;
    }
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
