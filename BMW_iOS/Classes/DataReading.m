//
//  DataReading.m
//  CoreDataTest2
//
//  Created by Aaron Sarnoff on 4/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataReading.h"


@implementation DataReading
@dynamic data;
@dynamic runID;
@dynamic itemID;
@dynamic readingType;

+ (DataReading *)addData:(NSDictionary *)dataDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    DataReading *dataReading = [NSEntityDescription insertNewObjectForEntityForName:@"DataReading" inManagedObjectContext:context];
    
    NSMutableData *data = [[[NSMutableData alloc]init] autorelease];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dataDictionary forKey: @"data"];
    [archiver finishEncoding];
    
    dataReading.data = data;
    
    return dataReading;
}

- (NSDictionary *)getParsedData
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self.data];
    NSDictionary *dict = [unarchiver decodeObjectForKey: @"data"];
    [unarchiver finishDecoding];
    [unarchiver release];
    return dict;
}

-(NSString *)description
{
    NSDictionary *dict = [self getParsedData];
    return [NSString stringWithFormat:@"runID:%@ itemID:%@ readingType:%@\ndata:%@\ndict:%@\n",self.runID, self.itemID, self.readingType, self.data, dict];
}

@end
