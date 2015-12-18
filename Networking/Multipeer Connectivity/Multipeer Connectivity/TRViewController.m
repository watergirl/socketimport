//
//  TRViewController.m
//  Multipeer Connectivity
//
//  Created by Tarena on 14-3-25.
//  Copyright (c) 2014年 Tarena. All rights reserved.
//

#import "TRViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface TRViewController () <MCBrowserViewControllerDelegate, UITextFieldDelegate, MCSessionDelegate>
@property (weak, nonatomic) IBOutlet UIButton *browserButton;
@property (weak, nonatomic) IBOutlet UITextField *chatBox;
@property (weak, nonatomic) IBOutlet UITextView *textBox;


@property (strong, nonatomic) MCPeerID *myPeerID;
@property (strong, nonatomic) MCSession *mySession;
@property (strong, nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@property (strong, nonatomic) MCBrowserViewController *browserViewController;

@end

@implementation TRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMultipeer];
    self.chatBox.delegate = self;
}

static NSString *ServiceType = @"chat";
- (void)setupMultipeer
{
    self.myPeerID = [[MCPeerID alloc]initWithDisplayName:[UIDevice currentDevice].name];
    self.mySession = [[MCSession alloc]initWithPeer:self.myPeerID];
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc]initWithServiceType:ServiceType discoveryInfo:nil session:self.mySession];
    self.browserViewController = [[MCBrowserViewController alloc]initWithServiceType:ServiceType session:self.mySession];
    
    self.browserViewController.delegate = self;
    self.mySession.delegate = self;
    [self.advertiserAssistant start];
}

- (void)showBrowserVC
{
    [self presentViewController:self.browserViewController animated:YES completion:nil];
}
- (void)dismissBrowserVC
{
    [self.browserViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)browserButtonTap
{
    [self showBrowserVC];
}


- (void)sendText
{
    NSString *message = self.chatBox.text;
    self.chatBox.text = @"";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.mySession sendData:data toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataReliable error:nil];
    [self receiveMessage:message fromPeer:self.myPeerID];
}

- (void)receiveMessage:(NSString *)message fromPeer:(MCPeerID *)peer
{
    NSString *finalMessage = nil;
    if (peer == self.myPeerID) {
        finalMessage = [NSString stringWithFormat:@"\nMe: %@\n", message];
    } else {
        finalMessage = [NSString stringWithFormat:@"\n%@: %@\n", peer.displayName, message];
    }
    self.textBox.text = [self.textBox.text stringByAppendingString:finalMessage];
}

#pragma mark - MCBrowserViewControllerDelegate
// Notifies the delegate, when the user taps the done button
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self dismissBrowserVC];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self dismissBrowserVC];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self sendText];
    return YES;
}

#pragma mark - MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString *message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self receiveMessage:message fromPeer:peerID];
    });
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}





@end
