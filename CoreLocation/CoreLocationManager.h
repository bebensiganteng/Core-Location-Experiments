//
//  CoreLocationManager.h
//  CoreLocation
//
//  Created by Rahmat Hidayat on 2014/07/14.
//  Copyright (c) 2014年 Rahmat Hidayat. All rights reserved.
/*

 Notes
 -------------
 The standard location service is a configurable, general-purpose solution for getting location data and tracking location changes for the specified level of accuracy.
 The significant-change location service delivers updates only when there has been a significant change in the device’s location, such as 500 meters or more.
 
 https://developer.apple.com/library/ios/documentation/userexperience/conceptual/LocationAwarenessPG/RegionMonitoring/RegionMonitoring.html
 Monitoring of a geographical region begins immediately after registration for authorized apps. However, don’t expect to receive an event right away, because only boundary crossings generate an event. In particular, if the user’s location is already inside the region at registration time, the location manager doesn’t automatically generate an event. Instead, your app must wait for the user to cross the region boundary before an event is generated and sent to the delegate. To check whether the user is already inside the boundary of a region, use the requestStateForRegion: method of the CLLocationManager class.
 
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Different approach, instead of using observer, using delegates might be more efficient
@protocol CoreLocationManagerDelegate <NSObject>

@required

- (void)locationUpdateTo: (CLLocation*)location;

@end

@interface CoreLocationManager : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager       *locationManager;
    
    CLCircularRegion        *circularRegion;
    CLBeaconRegion          *beaconRegion;
    CLBeacon                *closestBeacon;

    NSString                *beaconDistance;
    NSString                *sTimeStamp;
    NSString                *sAccuracy;
    NSString                *sRSSI;
    NSString                *sMajor;
    NSString                *sMinor;
    
    NSDate                  *timeStamp;
    
    CLLocationCoordinate2D  beaconLocation;
    BOOL                    isGeoFencing;
}


+ (CoreLocationManager *)sharedLocationManager;

// clue for improper use (produces compile time error)
+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedLocationManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedLocationManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedLocationManager instead")));


@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) id<CoreLocationManagerDelegate> delegate;
@property (nonatomic) CLLocationCoordinate2D beaconPosition;

- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID identifier:(NSString *)sID;

- (void)startMonitoringRegion;
- (void)stopMonitoringRegion;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)stopAll;

- (void) enableGeoFence:(CLLocationCoordinate2D)center locationDistance:(CLLocationDistance)radius;

@end
