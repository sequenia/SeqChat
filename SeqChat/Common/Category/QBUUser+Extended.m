//
//  QBUUser+Extended.m
//  SeqChat
//
//  Created by Denis Baluev on 22/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import "QBUUser+Extended.h"

@implementation QBUUser (Extended)

- (NSString*) stringID {
    return [NSString stringWithFormat:@"%ld", self.ID];
}

@end
