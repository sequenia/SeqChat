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

@interface ChatViewController () <QBChatDelegate>

@property (strong, nonatomic) NSMutableArray* messages;

@property (strong, nonatomic) JSQMessagesBubbleImageFactory* bubleFactory;

@property (strong, nonatomic) QBChatDialog* dialog;

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

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.senderId = self.user.stringID;
    self.senderDisplayName = self.user.fullName;
    
    [self joinToChatAndLoadMessages];

    UIBarButtonItem* logoutButton = [[UIBarButtonItem alloc] initWithTitle: @"Log out" style: UIBarButtonItemStylePlain target: self action:@selector(logout)];
    self.navigationItem.leftBarButtonItem = logoutButton;
}

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
    [QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
        [hud hide: YES];
        [self dismissViewControllerAnimated: YES completion: nil];
        NSLog(@"Successful logout");
    } errorBlock:^(QBResponse * _Nonnull response) {
        [hud hide: YES];
        NSLog(@"Logout failed");
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [[QBChat instance] addDelegate: self];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[QBChat instance] removeDelegate: self];
}

- (void) dealloc {
    [self.dialog leaveWithCompletionBlock:nil];
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
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Error loading messages. Response: %@", response);
        [hud hide:YES];
    }];
}

- (JSQMessage*) modelMessageToPresentMessage: (QBChatMessage*) message {
    return [[JSQMessage alloc] initWithSenderId: message.stringSenderID
                              senderDisplayName: message.senderNick ?: @"Nil"
                                           date: message.dateSent
                                           text: message.text];
}

#pragma mark - QBChatDelegate

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogId:(NSString *)dialogId{
    if ([dialogId isEqualToString: self.dialog.ID]){
        [self scrollToBottomAnimated:YES];
        
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.messages addObject: [self modelMessageToPresentMessage: message]];
        [self finishReceivingMessageAnimated:YES];
    }
}

- (void)chatDidReceiveMessage:(QB_NONNULL QBChatMessage *)message{

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
        return [self.bubleFactory outgoingMessagesBubbleImageWithColor: [UIColor lightGrayColor]];
    }
    
    return [self.bubleFactory incomingMessagesBubbleImageWithColor: [UIColor purpleColor]];
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
    
    QBChatMessage* message = [QBChatMessage message];
    message.senderID = [self.senderId integerValue];
    message.senderNick = senderDisplayName;
    message.text = text;
    message.dateSent = date;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
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
