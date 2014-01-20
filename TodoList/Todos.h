//
//  Todos.h
//  TodoList
//
//  Created by Ankit Nitin Shah on 1/20/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Todos : NSObject

@property (nonatomic, strong) NSMutableArray* items;

//Load existing todos from plist file.
- (void) loadItems;

//save todos to plist file
- (void) saveItems;

//return index of item with only whitespace characters. If none return -1
- (int) indexOfEmptyItem;

@end

