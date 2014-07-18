//
//  CoreLocationBasic.h
//  CoreLocation
//
//  Created by Rachmad Hidayat on 7/17/14.
//  Copyright (c) 2014 Rahmat Hidayat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#warning - Different approach, instead of using observer, using delegates might be more efficient
@protocol CoreLocationManagerDelegate <NSObject>

@required

- (void)locationError: (NSString*)msg;

@optional

- (void)locationUpdateTo: (CLLocation*)location;

@end

@interface CoreLocationBasic : NSObject <CLLocationManagerDelegate,CBPeripheralManagerDelegate> {
 
    CLLocationManager       *locationManager;
    CBPeripheralManager     *peripheralManager;
    
    NSDate                  *timeStamp;
    
    BOOL                    isGeoFencing;
    BOOL                    isBeacon;
    
    NSString                *isError;
    NSString                *beaconDistance;
    NSString                *sTimeStamp;
    NSString                *sAccuracy;
    NSString                *sRSSI;
    NSString                *sMajor;
    NSString                *sMinor;
    NSString                *sState;
}


@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) id<CoreLocationManagerDelegate> delegate;

- (void)setBluetooth;
- (void)setupLocationManager;
- (void)resetDispatcher;
- (BOOL)isConformedToProtocol;



@end
