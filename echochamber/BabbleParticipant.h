//
//  BabbleParticipant.h
//  echochamber
//
//  Created by James O'Brien on 18/09/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kBabbleEnteredRoom;
extern NSString* const kBabbleGotMessage;


@interface BabbleParticipant : NSObject
@property (strong, nonatomic, readonly) NSNotificationCenter *notifications;
@end
