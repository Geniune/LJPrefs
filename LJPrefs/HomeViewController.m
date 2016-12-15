//
//  HomeViewController.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "HomeViewController.h"
#import "VoiceRecordViewController.h"
#import "PrivacyPrefs.h"
#import "AddressBookViewController.h"
#import "SVProgressHUD.h"

static NSString *const mainCellIdentifer = @"UITableViewCell";

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    NSArray *_dataArr;
    
    NSMutableArray *_thisImgArr;
}

@property (nonatomic, strong) UITableView *mainTableView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"隐私";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _thisImgArr = [NSMutableArray array];
    //@[@"定位",@"通讯录",@"日历",@"提醒事项",@"照片",@"蓝牙共享",@"麦克风",@"语音识别",@"相机",@"健康",@"HomeKit",@"媒体资料库",@"运动与健身"];
    
    
    
    _dataArr = @[@"定位",@"通讯录",@"照片",@"麦克风",@"相机"];
    
    [self setupTableView];
}

- (void)setupTableView{
    
    _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height + 22.0f)];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:mainCellIdentifer];
    [self.view addSubview:_mainTableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifer];
    
    cell.textLabel.text = _dataArr[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0://定位
        {
            [PrefsLocation adjustPrivacySettingEnable:^(BOOL pFlag) {
                if(pFlag){
                    //调用定位方法
                    [SVProgressHUD showWithStatus:@"定位中..." maskType:SVProgressHUDMaskTypeNone];

                    [[PrefsLocation sharedInstance] requetLocationblock:^(CLLocation *location) {
                        [SVProgressHUD dismiss];
                        [[[UIAlertView alloc]initWithTitle:@"定位成功！" message:[NSString stringWithFormat:@"经度：%.4f，维度：%.4f",location.coordinate.longitude,location.coordinate.latitude] delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil] show];
                    }];
                }else{
                    [ICInfomationView initWithTitle:@"提示" message:@"定位权限被关闭，去隐私设置内打开" cancleButtonTitle:@"取消" OtherButtonsArray:@[@"去设置"] clickAtIndex:^(NSInteger buttonAtIndex) {
                        if(buttonAtIndex == 1){
                            [PrefsLocation openPrivacySetting];
                        }
                    }];
                }
            }];
        }
            break;
        case 1://通讯录
        {
            AddressBookViewController *VC = [[AddressBookViewController alloc]init];
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 2://照片
        {
            [PrefsPhoto adjustPrivacySettingEnable:^(BOOL pFlag) {
                if(pFlag){
                    //TODO:
                    [self showPhotoLibrary];
                }else{
                    [ICInfomationView initWithTitle:@"提示" message:@"相册权限被关闭，去隐私设置内打开" cancleButtonTitle:@"取消" OtherButtonsArray:@[@"去设置"] clickAtIndex:^(NSInteger buttonAtIndex) {
                        if(buttonAtIndex == 1){
                            [PrefsPhoto openPrivacySetting];
                        }
                    }];
                }
            }];
        }
            break;
        case 3://麦克风
        {
            VoiceRecordViewController *VC = [[VoiceRecordViewController alloc]initWithNibName:@"VoiceRecordViewController" bundle:nil];
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 4://相机
        {
            [PrefsCamera adjustPrivacySettingEnable:^(BOOL pFlag) {
                if(pFlag){
                    //TODO:
                    [self showCameraShoot];
                }else{
                    [ICInfomationView initWithTitle:@"提示" message:@"相机权限被关闭，去隐私设置内打开" cancleButtonTitle:@"取消" OtherButtonsArray:@[@"去设置"] clickAtIndex:^(NSInteger buttonAtIndex) {
                        if(buttonAtIndex == 1){
                            [PrefsCamera openPrivacySetting];
                        }
                    }];
                }
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 系统相册调用
- (void)showPhotoLibrary{
    
    UIImagePickerController *IMGPicker = [[UIImagePickerController alloc]init];
    IMGPicker.view.backgroundColor = [UIColor orangeColor];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypePhotoLibrary;
    IMGPicker.sourceType = sourcheType;
    IMGPicker.delegate = self;
    IMGPicker.allowsEditing = YES;
    [self presentViewController:IMGPicker animated:YES completion:nil];
}

#pragma mark - 系统自带相机调用
- (void)showCameraShoot{
    
    UIImagePickerController *IMGPicker = [[UIImagePickerController alloc]init];
    IMGPicker.view.backgroundColor = [UIColor orangeColor];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeCamera;
    IMGPicker.sourceType = sourcheType;
    IMGPicker.delegate = self;
    IMGPicker.allowsEditing = YES;
    [self presentViewController:IMGPicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *shootImg = [info objectForKey:UIImagePickerControllerEditedImage];
    if(shootImg){
        NSLog(@"照片获取成功");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
