//
//  AnnotationModel.m
//  JoggingApp
//
//  Created by Rahmat Hidayat on 2014/07/03.
//  Copyright (c) 2014年 Rahmat Hidayat. All rights reserved.
//

#import "AnnotationModel.h"

@implementation AnnotationModel

@synthesize coordinate = _coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    
    if (self != nil) {
        _coordinate = coordinate;
    }
    
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

- (void)setTitle:(NSString *) txt
{
    customTitle = txt;
}

- (void)setSubTitle:(NSString *)txt
{
    customSubtitle = txt;
}

- (NSString*)title
{
    return customTitle;
}

- (NSString*)subtitle
{
    return customSubtitle;
}

- (CLLocationCoordinate2D)getCoordinate
{
    return _coordinate;
}


@end
