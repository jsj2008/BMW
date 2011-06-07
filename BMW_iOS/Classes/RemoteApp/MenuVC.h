//
//  MenuVC.h
//  SimpleWeather
//
//  Created by Paul Doersch on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iDrive/iDrive.h>
#import "ServerConnection.h"
#import "RemoteAppIDs.h"
#import "RemoteApp.h"

@interface MenuVC : IDViewController <ServerConnectionDelegate> {
	IDTable* list;
    NSMutableArray *rankingResults;
}
@property(retain) IDTable* list;

NSComparisonResult comparator();
-(void)populateList;
-(void)listElementSelected:(NSNumber*)indexNum;

@end
