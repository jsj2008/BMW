//
//  DataReading.h
//  CoreDataTest2
//
//  Created by Aaron Sarnoff on 4/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataReading : NSManagedObject {
@private
}

+ (DataReading *)addData:(NSDictionary *)dataDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
- (NSDictionary *)getParsedData;

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * runID;
@property (nonatomic, retain) NSNumber * readingType;
@property (nonatomic, retain) NSNumber * itemID;

@end
