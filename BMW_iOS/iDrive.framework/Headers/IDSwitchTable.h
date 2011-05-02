//
//  IDSwitchTable.h
//  iDrive
//
//  Created by Paul Doersch on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IDSwitchTableSupportedSchema 1

// AppSwitchTable Dictionary
#define IDSwitchTableVersionKey @"Version"	// Increments when App information is updates
#define IDSwitchTableSchemaKey @"Schema"	// Increments when the Dictionary format is updated
#define IDSwitchTableAppsKey @"Apps"		// Contains Dictionary of App Dictionaries

// App Dictionary
#define IDSwitchTableAppNameKey @"Name"
#define IDSwitchTableAppURLKey @"URL"

extern NSString* IDSwitchTableDidUpdate;

@interface IDSwitchTable : NSObject {
	NSDictionary* mLocalTableCache;
}
@property (retain) NSDictionary* localTableCache;

- (NSArray*)installedAppsTable;
- (NSArray*)notInstalledAppsTable;

- (void)switchTo:(NSDictionary*)appEntry;

+ (NSDictionary*)tableWithUrl:(NSURL*)url;
+ (NSURL*)urlWithUrl:(NSString*)url table:(NSDictionary*)table;

- (void)fetchRemoteTable;

@end
