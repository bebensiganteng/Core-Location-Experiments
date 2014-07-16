//
//  MapViewController.h
//  CoreLocation
//
//  Created by Rachmad Hidayat on 7/15/14.
//  Copyright (c) 2014 Rahmat Hidayat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreLocationManager.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CoreLocationManagerDelegate> {
 
    CoreLocationManager     *clManager;
    IBOutlet MKMapView      *map;
    
    BOOL                    isZoomed;
}

@end
