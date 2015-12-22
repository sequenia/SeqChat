//
//  ViewController.m
//  SeqChat
//
//  Created by Denis Baluev on 21/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import "ChatViewController.h"
#import <JSQSystemSoundPlayer.h>

@interface ChatViewController () 

@property (strong, nonatomic) NSMutableArray* messages;

@property (strong, nonatomic) JSQMessagesBubbleImageFactory* bubleFactory;

@end

@implementation ChatViewController

- (instancetype) initWithUser: (QBUUser*) user {
    if (self = [super init]){
        _user = user;
        _messages = [NSMutableArray array];
        _bubleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.senderId = self.user.login;
    self.senderDisplayName = self.user.fullName;
    
    [[QBChat instance] connectWithUser: self.user completion:^(NSError * _Nullable error) {
        if (error){
            NSLog(@"Error chat connecting : %@", error.localizedDescription);
        }
    }];
    
    
    
    QBChatDialog* dialog = [[QBChatDialog alloc] initWithDialogID:@"5677ae4ea0eb47c5bb001663" type: QBChatDialogTypePublicGroup];
    QBChatMessage* m = [[QBChatMessage alloc] init];
    
    [dialog joinWithCompletionBlock:^(NSError * _Nullable error) {
        NSLog(@"Error joining : %@", error.localizedDescription);
    }];
    m.text = @"QBChatMessage";
    [dialog sendMessage: m completionBlock:^(NSError * _Nullable error) {
        NSLog(@"Error sending message: %@", error.localizedDescription);
    }];
    
    JSQMessage* message = [JSQMessage messageWithSenderId: self.senderId displayName: self.senderDisplayName text: @"Test message"];
    JSQMessage* mes = [JSQMessage messageWithSenderId:@"1sender" displayName: @"sender 1" text: @"Hey"];
    [self.messages addObject: mes];
    [self.messages addObject: message];
    
    // Do any additional setup after loading the view, typically from a nib.
    
}

#pragma mark - JSQMessagesViewController method overrides

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    return nil;
}


- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return [self.bubleFactory outgoingMessagesBubbleImageWithColor: [UIColor greenColor]];
    }
    
    return [self.bubleFactory outgoingMessagesBubbleImageWithColor: [UIColor grayColor]];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate: nil
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messages removeObjectAtIndex:indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}


@end
