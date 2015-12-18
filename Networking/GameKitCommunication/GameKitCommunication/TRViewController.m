//
//  TRViewController.m
//  GameKitCommunication
//
//  Created by Tarena on 14-3-24.
//  Copyright (c) 2014年 Tarena. All rights reserved.
//

#import "TRViewController.h"
#import <GameKit/GameKit.h>

#define GAMING 0   //游戏进行中
#define GAMED  1   //游戏结束

@interface TRViewController () <GKPeerPickerControllerDelegate, GKSessionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;

@property (weak, nonatomic) IBOutlet UIButton *clickButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@property (strong, nonatomic) GKSession *session;
@property (strong, nonatomic) GKPeerPickerController *pickerController;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation TRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self clearUI];
}
- (GKPeerPickerController *)pickerController
{
    if (!_pickerController) {
        _pickerController = [[GKPeerPickerController alloc]init];
        _pickerController.delegate = self;
        _pickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        
    }
    return _pickerController;
}
- (IBAction)onClick:(UIButton *)sender
{
    int count = [self.timerLabel.text intValue];
    self.player1Label.text = [NSString stringWithFormat:@"%i", ++count];
    NSString *sendStr = [NSString stringWithFormat:@"{\"code\":%i,\"count:\":%i", GAMING, count];
    NSData *data = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
    if (self.session) {
        [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSNumber * codeObj = [jsonObj objectForKey:@"code"];
    if ([codeObj intValue] == GAMING) {
        NSNumber *countObj = [jsonObj objectForKey:@"count"];
        self.player2Label.text = [NSString stringWithFormat:@"%@", countObj];
    }else if([codeObj intValue] == GAMED) {
        [self clearUI];
    }
}

- (IBAction)connect:(UIButton *)sender
{
    [self.pickerController show];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    NSLog(@"建立连接");
    self.session = session;
    self.session.delegate = self;
    [self.session setDataReceiveHandler:self withContext:nil];
    self.pickerController.delegate = nil;
    [self.pickerController dismiss];
    self.clickButton.enabled = YES;
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

- (void)updateTimer
{
    int remainTime = [self.timerLabel.text intValue];
    if (--remainTime == 0) {
        NSString *sendStr = [NSString stringWithFormat:@"\"code\":%i", GAMED];
        NSData *data = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
        if(self.session) {
            [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
        }
        [self.timer invalidate];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Game Over." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        self.timerLabel.text = [NSString stringWithFormat:@"%is", remainTime];
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (state == GKPeerStateConnected) {
        NSLog(@"connected");
        [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        self.clickButton.enabled = YES;
    }else if (state == GKPeerStateDisconnected) {
        NSLog(@"disconnected");
        [self clearUI];
    }
}

- (void)clearUI
{
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    self.clickButton.enabled = NO;
    self.player2Label.text = @"0";
    self.player1Label.text = @"0";
    self.timerLabel.text = @"30s";
}



@end
