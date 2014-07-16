//
//  AnnotationModel.h
//  JoggingApp
//
//  Created by Rahmat Hidayat on 2014/07/03.
//  Copyright (c) 2014年 Rahmat Hidayat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnotationModel : NSObject <MKAnnotation> {
    CLLocationCoordinate2D  _coordinate;
    NSString                *customTitle;
    NSString                *customSubtitle;
}

- (id)initWithCoordinate    :(CLLocationCoordinate2D)coordinate;
- (void)setCoordinate       :(CLLocationCoordinate2D)newCoordinate;
- (NSString*) title;
- (NSString*) subtitle;

- (void)setTitle            :(NSString*) txt;
- (void)setSubTitle         :(NSString*) txt;
- (CLLocationCoordinate2D)getCoordinate;

@end
