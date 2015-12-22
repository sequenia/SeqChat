//
//  NSArray+HOM.m
//  SeqChat
//
//  Created by Denis Baluev on 22/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import "NSArray+HOM.h"

@implementation NSArray (HOM)

- (NSArray*) map: ( id(^)(id obj) ) block {
    NSMutableArray* mappedArray = [[NSMutableArray alloc] initWithCapacity: self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id newObj = block(obj);
        if (newObj){
            [mappedArray addObject: newObj];
        }
    }];
    return mappedArray;
}

@end
