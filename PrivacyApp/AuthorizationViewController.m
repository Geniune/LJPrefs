//
//  AuthorizationViewController.m
//  PrivacyApp
//
//  Created by Apple on 2019/11/26.
//  Copyright © 2019 Geniune. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "LSAuthorizationManager.h"

/**
 *  屏幕大小常量
 */
#define APP_W               [UIScreen mainScreen].applicationFrame.size.width
#define APP_H               [UIScreen mainScreen].applicationFrame.size.height

#define SCREEN_W            [UIScreen mainScreen].bounds.size.width  //屏幕宽
#define SCREEN_H            [UIScreen mainScreen].bounds.size.height //屏幕高

@interface AuthorizationViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    NSArray *titleArray;
    NSArray *detailArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AuthorizationViewController
                                                                       
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"隐私权限";
    
    titleArray = @[@"Apple Music", @"Bluetooth", @"Calendar", @"Camera", @"Contacts", @"Health", @"Home", @"Location", @"Microphone", @"Motion", @"Photos", @"Reminders", @"Siri（未实现）"];
    detailArray = @[@"音乐", @"蓝牙", @"日历", @"相机", @"联系人", @"健康", @"家庭", @"定位", @"麦克风", @"运动", @"相册", @"提醒事项", @"Siri"];
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView{
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = NSStringFromClass([self class]);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    cell.textLabel.text = titleArray[indexPath.row];
    cell.detailTextLabel.text = detailArray[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {

        case 0://音乐
        {
            [AUTHORIZATIONMANAGER checkAppleMusicAuthorization];
        }
            break;
        case 1://蓝牙
        {
            [AUTHORIZATIONMANAGER checkBluetoothAuthorization];
        }
            break;
        case 2://日历
        {
           [AUTHORIZATIONMANAGER checkCalendarsAuthorization];
        }
           break;
        case 3://相机
        {
           [AUTHORIZATIONMANAGER checkCameraAuthorization];
        }
           break;
        case 4://联系人
        {
           [AUTHORIZATIONMANAGER checkContactsAuthorization];
        }
           break;
        case 5://健康
        {
            [AUTHORIZATIONMANAGER checkHealthAuthorization];
        }
           break;
        case 6://家庭
        {
           [AUTHORIZATIONMANAGER checkHomeKitAuthorization];
        }
           break;
        case 7://定位
        {
           [AUTHORIZATIONMANAGER checkLocationAuthorization];
        }
            break;
        case 8://麦克风
       {
          [AUTHORIZATIONMANAGER checkMicrophoneAuthorization];
       }
          break;
        case 9://运动
        {
            [AUTHORIZATIONMANAGER checkMotionAuthorization];
        }
           break;
        case 10://相册
        {
           [AUTHORIZATIONMANAGER checkPhotosAuthorization];
        }
           break;
        case 11://提醒事项
        {
           [AUTHORIZATIONMANAGER checkRemindersAuthorization];
        }
           break;
        case 12://Siri
        {
           [AUTHORIZATIONMANAGER checkSiriAuthorization];
        }
           break;

        default:
            break;
    }
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
