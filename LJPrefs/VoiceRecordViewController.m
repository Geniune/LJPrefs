//
//  VoiceRecordViewController.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "VoiceRecordViewController.h"
#import "PrefsMicrophone.h"




@interface VoiceRecordViewController (){
    
    AVAudioRecorder *recorder;
    NSTimer *timer;
    AVAudioPlayer *player;
    NSURL *recordURL;
    
    int recordEncoding;
    enum
    {
        ENC_AAC = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM = 6,
    } encodingTypes;
}

@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;

@end

@implementation VoiceRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"麦克风";
    
    recordEncoding = ENC_AAC;
    
    [_recordBtn addTarget:self action:@selector(downAction:) forControlEvents:UIControlEventTouchDown];
    [_stopBtn addTarget:self action:@selector(upAction:) forControlEvents:UIControlEventTouchDown];
    
    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)downAction:(id)sender {
    
    [PrefsMicrophone adjustPrivacySettingEnable:^(BOOL pFlag) {
        if(pFlag){
            //TODO:
            [self startRecordAction];
            
        }else{
            [ICInfomationView initWithTitle:@"提示" message:@"麦克风权限被关闭，去隐私设置内打开" cancleButtonTitle:@"取消" OtherButtonsArray:@[@"去设置"] clickAtIndex:^(NSInteger buttonAtIndex) {
                if(buttonAtIndex == 1){
                    [PrefsMicrophone openPrivacySetting];
                }
            }];
        }
    }];
  
}

- (void)startRecordAction{
    
    // Init audio with record capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    NSError *error = nil;
    //必须真机上测试,模拟器上可能会崩溃
    recordURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", [[NSBundle mainBundle] resourcePath]]];
    if(recorder == nil){
        recorder = [[AVAudioRecorder alloc] initWithURL:recordURL settings:recordSettings error:&error];
    }
    
    
    if ([recorder prepareToRecord]){
        [_recordBtn setTitle:@"录音中..." forState:UIControlStateNormal];
        _recordBtn.enabled = NO;
        [recorder record];
    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
}

- (void)upAction:(id)sender {
    //松开 结束录音
    
    [_recordBtn setTitle:@"录音" forState:UIControlStateNormal];
    _recordBtn.enabled = YES;
    
    //录音停止
    [recorder stop];
    recorder = nil;
    //结束定时器
    [timer invalidate];
    timer = nil;
    
}

- (void)playAction:(id)sender {
    
    if(recordURL){
        
        NSError *playerError;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        //播放
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordURL error:&playerError];
        
        if(player == nil)
        {
            NSLog(@"ERror creating player: %@", [playerError description]);
        }else{
            [player play];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
