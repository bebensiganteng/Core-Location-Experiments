//
//  TableViewController.h
//  CoreLocation
//
//  Created by Rahmat Hidayat on 2014/07/14.
//  Copyright (c) 2014年 Rahmat Hidayat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocationManager.h"

@interface TableViewController : UITableViewController {
    
    CoreLocationManager     *clManager;
    
    IBOutlet UILabel        *labelLocStatus;
    IBOutlet UILabel        *labelTimeStamp;
    IBOutlet UILabel        *labelAccuracy;
    IBOutlet UILabel        *labelRSSI;
    IBOutlet UILabel        *labelMajor;
    IBOutlet UILabel        *labelMinor;
    
    IBOutlet UITextField    *tfName;
    IBOutlet UITextField    *tfUUID;
    IBOutlet UITextField    *tfLat;
    IBOutlet UITextField    *tfLong;
    
    NSRegularExpression     *uuidRegex;

}

@property (strong, nonatomic) IBOutlet UIButton *btnAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnCurr;

@end
