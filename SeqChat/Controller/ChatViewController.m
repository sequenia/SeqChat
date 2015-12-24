//
//  ViewController.m
//  SeqChat
//
//  Created by Denis Baluev on 21/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import "ChatViewController.h"
#import <JSQSystemSoundPlayer.h>
#import <MBProgressHUD.h>
#import "Categories.h"

NSString* const kDisplayedName = @"kDisplayedName";

NSString* const seqID   = @"7742063";
NSString* const denisID = @"7744596";
NSString* const nickID  = @"7744975";

CGFloat const topLabelHeight = 20.0;

@interface ChatViewController () <QBChatDelegate>

@property (strong, nonatomic) NSMutableArray* messages;

@property (strong, nonatomic) NSDictionary* avatars;

@property (strong, nonatomic) JSQMessagesBubbleImageFactory* bubleFactory;

@property (strong, nonatomic) QBChatDialog* dialog;

@end

@implementation ChatViewController

- (instancetype) initWithUser: (QBUUser*) user {
    if (self = [super init]){
        _user = user;
        _messages = [NSMutableArray array];
        _bubleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        [self setupAvatars];
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAppeareance];
    
    self.senderId = self.user.stringID;
    self.senderDisplayName = self.user.fullName;
    
    [self joinToChatAndLoadMessages];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [[QBChat instance] addDelegate: self];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[QBChat instance] removeDelegate: self];
}

#pragma mark - Preparation

- (void) setupAvatars {
    UIImage* seqImage = [self circularImageFromImage: [UIImage imageNamed: @"sequenia_logo"]];
    UIImage* denisImage = [self circularImageFromImage: [UIImage imageNamed: @"denis.gif"]];
    UIImage* nickImage = [self circularImageFromImage: [UIImage imageNamed:@"nick.gif"]];
    JSQMessagesAvatarImage* denisAvatar = [JSQMessagesAvatarImage avatarWithImage: denisImage];
    JSQMessagesAvatarImage* nickAvatar = [JSQMessagesAvatarImage avatarWithImage: nickImage];
    JSQMessagesAvatarImage* seqAvatar = [JSQMessagesAvatarImage avatarWithImage: seqImage];
    self.avatars = @{seqID  : seqAvatar,
                     denisID: denisAvatar,
                     nickID : nickAvatar};
}

- (void) configureAppeareance {
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bg_pattern"]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UIImage* closeBtmImage = [[UIImage imageNamed:@"close40"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImageView* closeImageView = [[UIImageView alloc] initWithImage: closeBtmImage];
    closeImageView.userInteractionEnabled = YES;
    [closeImageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(logout)]];
    closeImageView.frame = CGRectMake(0, 0, 25.0, 25.0);
    UIBarButtonItem* logoutButton = [[UIBarButtonItem alloc] initWithCustomView: closeImageView];
    self.navigationItem.leftBarButtonItem = logoutButton;
}

#pragma mark - Requests

- (void) joinToChatAndLoadMessages {
    QBChatDialog* dialog = [[QBChatDialog alloc] initWithDialogID:@"5677ae4ea0eb47c5bb001663" type: QBChatDialogTypeGroup];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.labelText = @"Joining to chat";
    __weak typeof(self) welf = self;
    [dialog joinWithCompletionBlock:^(NSError * _Nullable error) {
        [hud hide:YES];
        if (error){
            NSLog(@"Error joining : %@", error.localizedDescription);
        } else {
            [welf loadMessagesFromDialog: dialog];
        }
    }];
    self.dialog = dialog;
}

- (void) logout {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.labelText = @"Log out...";
    [[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        [QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
            [hud hide: YES];
            [self dismissViewControllerAnimated: YES completion: nil];
            NSLog(@"Successful logout");
        } errorBlock:^(QBResponse * _Nonnull response) {
            [hud hide: YES];
            NSLog(@"Logout failed");
        }];
    }];
    
}

- (void) loadMessagesFromDialog: (QBChatDialog*) dialog {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.labelText = @"Loading history";
    [QBRequest messagesWithDialogID: dialog.ID successBlock:^(QBResponse * _Nonnull response, NSArray<QBChatMessage *> * _Nullable messages) {
        
        NSArray* mappedMessages = [messages map:^id(id obj) {
            QBChatMessage* oldMessage = (QBChatMessage*) obj;
            return [self modelMessageToPresentMessage: oldMessage];
        }];
        self.messages = [NSMutableArray arrayWithArray:mappedMessages];
        [self.collectionView reloadData];
        [hud hide: YES];
        [self scrollToBottomAnimated: YES];
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Error loading messages. Response: %@", response);
        [hud hide:YES];
    }];
}


#pragma mark - Mapping

- (JSQMessage*) modelMessageToPresentMessage: (QBChatMessage*) message {
    NSString* displayedName = [message customParameters][kDisplayedName];
    return [[JSQMessage alloc] initWithSenderId: message.stringSenderID
                              senderDisplayName: displayedName
                                           date: message.dateSent
                                           text: message.text];
}

#pragma mark - QBChatDelegate

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID{
    if ([dialogID isEqualToString: self.dialog.ID]){
        
        if ([message.stringSenderID isEqualToString: self.senderId]){
            return;
        }
        
        [self scrollToBottomAnimated:YES];
        
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.messages addObject: [self modelMessageToPresentMessage: message]];
        [self finishReceivingMessageAnimated:YES];
    }
}

- (void)chatDidConnect {
    [self joinToChatAndLoadMessages];
}

#pragma mark - JSQMessagesCollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    return topLabelHeight;
}

#pragma mark - Override super methods

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {

    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    QBChatMessage* message = [QBChatMessage message];
    message.senderID = [self.senderId integerValue];
    message.senderNick = senderDisplayName;
    message.text = text;
    message.dateSent = date;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    params[kDisplayedName] = senderDisplayName;
    [message setCustomParameters:params];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated: YES];
    hud.labelText = @"Sending...";
    __weak typeof(self) welf = self;
    [self.dialog sendMessage: message completionBlock:^(NSError * _Nullable error) {
        [hud hide: YES];
        if (error){
            NSLog(@"Error sending message: %@", error.localizedDescription);
        } else {
            [welf.messages addObject: [self modelMessageToPresentMessage: message]];
            [welf finishSendingMessageAnimated:YES];
        }
    }];

}

- (void)didPressAccessoryButton:(UIButton *)sender{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate: nil
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return [self.bubleFactory outgoingMessagesBubbleImageWithColor: [UIColor lightGrayColor]];
    }
    return [self.bubleFactory incomingMessagesBubbleImageWithColor: [UIColor purpleColor]];
}


- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    return [self.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

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

#pragma mark - Drawings

- (UIImage*) circularImageFromImage: (UIImage*) image {
    return [[self class] circularImage: image withDiameter: 20.0 highlightedColor: nil];
}

+ (UIImage *)circularImage:(UIImage *)image withDiameter:(NSUInteger)diameter highlightedColor:(UIColor *)highlightedColor
{
    NSParameterAssert(image != nil);
    NSParameterAssert(diameter > 0);
    
    CGRect frame = CGRectMake(0.0f, 0.0f, diameter, diameter);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIBezierPath *imgPath = [UIBezierPath bezierPathWithOvalInRect:frame];
        [imgPath addClip];
        [image drawInRect:frame];
        
        if (highlightedColor != nil) {
            CGContextSetFillColorWithColor(context, highlightedColor.CGColor);
            CGContextFillEllipseInRect(context, frame);
        }
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
