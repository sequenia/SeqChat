//
//  NSArray+HOM.h
//  SeqChat
//
//  Created by Denis Baluev on 22/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (HOM)

- (NSArray*) map: ( id(^)(id obj) ) block;

@end
