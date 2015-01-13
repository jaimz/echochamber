//
//  BabbleParticipant.m
//  echochamber
//
//  Created by James O'Brien on 18/09/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import "BabbleParticipant.h"
#import <SRWebSocket.h>
#import <objc/runtime.h>

NSString* const kBabbleEnteredRoom = @"babble.entered.room";
NSString* const kBabbleGotMessage = @"babble.got.message";

@interface BabbleParticipant () <SRWebSocketDelegate> {
  NSString *_serverUri;
  SRWebSocket *_connection;
  BOOL _opened;
  NSString *_currentRoom;
  
  NSDictionary *_cmdTable;
};

@end


@implementation BabbleParticipant

@synthesize notifications = _notifications;

- (id)init
{
  self = [super init];
  if (self) {
    _notifications = [[NSNotificationCenter alloc] init];
    _cmdTable = @{@"hello": @"enteredRoom:withDescription:",
                  @"chat": @"gotChatForRoom:withChat:",
                  @"goodbye": @"gotGoodbyeFromRoom:withMessage:"};
  }
  
  return self;
}

- (void)connect:(NSString *)serverAddress
{
  NSURL *serverUrl = [NSURL URLWithString: serverAddress];
  
  _connection = [[SRWebSocket alloc] initWithURL:serverUrl];
  _connection.delegate = self;
  [_connection open];
}

- (void)enteredRoom:(NSString *)room withDescription:(NSString *)jsonDescription
{
/*  _currentRoom = room;
  
  NSData *iNeedData = [jsonDescription dataUsingEncoding:NSUTF8StringEncoding];
  
  NSError *parsingError = nil;
  NSDictionary *roomDescription = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:iNeedData options:0 error:&parsingError];
  
  if (parsingError) {
    NSLog(@"Got a JSON Parsing error: %@", [parsingError localizedDescription]);
    return;
  }
  */
//  NSArray *participants = [roomDescription objectForKey:@"participants"];
}

- (void)gotChatForRoom:(NSString *)room withChat:(NSString *)jsonChat
{
  
}

- (void)gotGoodbyeFromRoom:(NSString *)room withMessage:(NSString *)message
{
  
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
  NSLog(@"Got message: %@", message);
  NSString *sMsg = (NSString *)message;

  /*
   The response from the server should be of the form:
   <room name>\n
   <response label>\n (e.g. hello | goodbye | chat)
   <response data> (optional)
   */
  
  NSString *room = nil;
  NSString *cmd = nil;
  NSString *cmdParam = nil;
  NSArray *comps = [sMsg componentsSeparatedByString:@"\n"];
  NSUInteger l = [comps count];
  
  if (l > 1) {
    room = comps[0];
    cmd = comps[1];
    
    if (l > 2)
      cmdParam = comps[3];
  } else {
    NSLog(@"Don't understand response from server: %@", sMsg);
  }
  
  // TODO: Not sure how much slower this is than a massive if/else chain.
  // We can't just store the selectors in the cmdTable since they are not
  // obj-c objects (CFDictionary?)
  id selectorString = [_cmdTable objectForKey:cmd];
  SEL selector = NSSelectorFromString((NSString *)selectorString);
  objc_msgSend(self, selector, room, cmdParam);
}


- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
  NSLog(@"Web socket opened");
  _opened = YES;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
  NSLog(@"Web socket errored %@", [error localizedDescription]);
}


- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
  if (!wasClean) {
    NSLog(@"Web socket closed: %@", reason);
  }
  
  _connection = nil;
  _serverUri = nil;
  _opened = NO;
}

@end
