//
//  MapViewController.m
//  CoreLocation
//
//  Created by Rachmad Hidayat on 7/15/14.
//  Copyright (c) 2014 Rahmat Hidayat. All rights reserved.
//

#import "MapViewController.h"
#import "AnnotationModel.h"

@interface MapViewController ()

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    clManager           = [CoreLocationManager sharedLocationManager];
    clManager.delegate  = self;
    
    [self initMap];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

#pragma mark - Corelocation

- (void)locationUpdateTo: (CLLocation*)location
{
    NSLog(@"locationUpdateTo location:%f %f", location.coordinate.latitude, location.coordinate.longitude);
    
    if ([self isItActive])
    {
        double maxLat = -200;
        double minLat =  200;
        double maxLon = -200;
        double minLon =  200;
        
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        if (coordinate.latitude > maxLat)
            maxLat = coordinate.latitude;
        if (coordinate.latitude < minLat)
            minLat = coordinate.latitude;
        
        if (coordinate.longitude > maxLon)
            maxLon = coordinate.longitude;
        if (coordinate.longitude < minLon)
            minLon = coordinate.longitude;
        
        MKCoordinateRegion region;
        region.span.latitudeDelta  = (maxLat +  90) - (minLat +  90);
        region.span.longitudeDelta = (maxLon + 180) - (minLon + 180);
        
        region.center.latitude  = minLat + region.span.latitudeDelta / 2;
        region.center.longitude = minLon + region.span.longitudeDelta / 2;
        
        [map setRegion:region animated:YES];
        
        [clManager.locationManager stopUpdatingLocation];
        
    }
}

#pragma mark - Map
     
- (void)initMap
{
    map.mapType                 = MKMapTypeStandard;
    map.delegate                = self;
    map.showsUserLocation       = YES;
}

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        
        MKCircleRenderer *circleRender  = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        circleRender.strokeColor        = [UIColor redColor];
        circleRender.lineWidth          = 1.0;
        circleRender.fillColor          = [[UIColor redColor] colorWithAlphaComponent:0.6];
        
        return circleRender;
    }
    
    return nil;
}

#pragma mark - CoreLocation
-(void)locationError:(NSString *)msg
{
    [self showMessage:msg];
}

#pragma mark - Default
- (void)enterForeground:(NSNotification*)notification
{
    if (clManager) [clManager.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)enterBackground:(NSNotification*)notification
{
    if (clManager) [clManager.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    double rad = clManager.getCircularRegion.radius;
    
    if(rad > 0) {
        
        if([map.overlays count] > 0) {
            [map removeOverlays:map.overlays];
        }
        
        CLLocationCoordinate2D coord = clManager.getCircularRegion.center;
        
        // Add Circle
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:rad];
        
        [map addOverlay:circle];
    }
    
    [clManager.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[clManager stopAll];
    //[clManager startMonitoringRegion];
}

#pragma mark - Utils


-(void) showMessage:(NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"iBeacon"
                              message:message
                              delegate:self
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:Nil, nil];
    
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    
    [alertView show];
    
}

- (BOOL)isItActive
{
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
    {
        return TRUE;
    }
    
    return FALSE;
}

/*
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"mapviewController");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

@end
