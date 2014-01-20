//
//  Todos.m
//  TodoList
//
//  Created by Ankit Nitin Shah on 1/20/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "Todos.h"

@implementation Todos

-(id)init{
    self = [super init];
    if(self){
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) loadItems{

    NSString *error;
    NSPropertyListFormat format;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"ToDo.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"ToDo" ofType:@"plist"];
    }
    NSLog(@"Loading from file: %@",plistPath);
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSArray *temp = (NSArray *)[NSPropertyListSerialization
                                propertyListFromData:plistXML
                                mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                format:&format
                                errorDescription:&error];
    if (!temp) {
        NSLog(@"Error reading file: %@, format: %d", error, format);
    }
    self.items = [NSMutableArray arrayWithArray:temp];
    NSLog(@"Loaded items count: %d", [self.items count]);

}


- (void) saveItems{
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"ToDo.plist"];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:self.items format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    NSLog(@"Saving to file: %@",plistPath);
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"Error writing file : %@",error);
    }
    NSLog(@"Saved items count: %d", [self.items count]);
}


-(int) indexOfEmptyItem{
    for(int i = 0 ; i < self.items.count ; i++){
        NSString* trimmedVal = [self.items[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
        if(trimmedVal.length == 0){
            return i;
        }
    }
    return -1;
}

@end
