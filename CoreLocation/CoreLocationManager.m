//
//  CoreLocationManager.m
//  CoreLocation
//
//  Created by Rahmat Hidayat on 2014/07/14.
//  Copyright (c) 2014年 Rahmat Hidayat. All rights reserved.
//


#import "CoreLocationManager.h"

@implementation CoreLocationManager

#pragma mark - Init

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
        
        locationManager = nil;
        [self setBluetooth];
        
    }
    
    return self;
}


- (BOOL)startCoreLocation
{
    
    if ([isError length] > 0) {
        [self.delegate locationError:isError];
        
        return NO;
    }
    
    // ensure everything is stopped
    [self stopCoreLocation];
    
    // 2: check if the device inside the region
    [locationManager startMonitoringForRegion:circularRegion];
    // TODO: use block code
    // http://www.cocoanetics.com/2014/05/radar-monitoring-clregion-immediately-after-removing-one-fails/
    [self performSelector:@selector(requestState:) withObject:circularRegion afterDelay:1];
    
    isGeoFencing = YES;
    
    return isGeoFencing;
}

- (void)stopCoreLocation
{
    if (isGeoFencing) {
        [self stopMonitoringRegions];
    }
    
    if (isBeacon) {
        [self stopBeacon];
    }
    
    [self resetDispatcher];
}

- (void)requestState:(CLRegion*)region
{
    [self.locationManager requestStateForRegion:region];
}

#pragma mark - GeoFencing

- (void) registerGeoFence:(CLLocationCoordinate2D)center locationDistance:(CLLocationDistance)radius
{
    
    if (radius > locationManager.maximumRegionMonitoringDistance) {
        radius = locationManager.maximumRegionMonitoringDistance;
    }
    
    // Create the geographic region to be monitored. iOS 8.0
    circularRegion = [[CLCircularRegion alloc]
                      initWithCenter:center
                      radius:radius
                      identifier:@"com.bebensiganteng.geofencing"];
    
    
    circularRegion.notifyOnEntry    = YES;
    circularRegion.notifyOnExit     = YES;
    
    BOOL monitoringAvailability = [CLLocationManager isMonitoringAvailableForClass:[circularRegion class]];
    
    if(!monitoringAvailability ) {
        isError = @"GeoFencing Error";
        return;
    }

}

- (CLCircularRegion *)getCircularRegion
{
    return circularRegion;
}

- (void)stopMonitoringRegions
{
    // ensure everything is cleared
    for (CLRegion *region in [locationManager monitoredRegions]) {
        [locationManager stopMonitoringForRegion:region];
    }
    
    isGeoFencing = NO;
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
    if ([self isConformedToProtocol]) {
        [self.delegate locationError:error.description];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    if ([self isConformedToProtocol]) {
        [self.delegate locationError:error.description];
    }
}

#pragma mark - Default delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ([self isConformedToProtocol]) {
        [self.delegate locationUpdateTo:newLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed: %@", error);
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //[self setup];
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
    
}

- (void)startBeacon
{
    isBeacon = YES;
    
    //[locationManager startMonitoringForRegion:beaconRegion];
    [locationManager startRangingBeaconsInRegion:beaconRegion];

}

- (void)stopBeacon
{
    isBeacon = NO;
    
    [locationManager stopRangingBeaconsInRegion:beaconRegion];

}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
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
            
            [self setValue:@"CLRegionStateUnknown" forKey:@"sState"];

            if ([self isConformedToProtocol]) {
                [self.delegate locationError:@"CLRegionStateUnknown"];
            }
            
            if (isGeoFencing) {
                [self stopMonitoringRegions];
            }
            
            break;
            
        case CLRegionStateInside:
            
            [self setValue:@"CLRegionStateInside" forKey:@"sState"];

            // 3: if inside region, start Ranging
            if (!isBeacon) {
                [self startBeacon];
            }
            
            break;
            
        case CLRegionStateOutside:
            
            [self setValue:@"CLRegionStateOutside" forKey:@"sState"];

            // 4: if outside region, stop Ranging
            if (isBeacon) {
                [self stopBeacon];
            }
            
            break;
    }
}


@end
