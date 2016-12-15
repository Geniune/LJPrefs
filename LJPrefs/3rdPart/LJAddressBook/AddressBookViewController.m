//
//  AddressBookViewController.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "AddressBookViewController.h"
#import "PrefsAddressBook.h"
#import "ContactModel.h"
#import "SVProgressHUD.h"

static NSString *const mainCellIdentifer = @"UITableViewCell";

@interface AddressBookViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    
    
    NSArray *_rowArr;//row arr
    NSMutableArray *_sectionArr;//section arr
}

@property (nonatomic, strong) UITableView *mainTableView;

@end

@implementation AddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"通讯录";
    
    [SVProgressHUD showWithStatus:@"请稍等" maskType:SVProgressHUDMaskTypeNone];
    
    [self setupTableView];
}

- (void)viewDidAppear:(BOOL)animated{

    [self loadPerson];
}

- (void)loadPerson
{
    [PrefsAddressBook adjustPrivacySettingEnable:^(BOOL pFlag) {
        if(pFlag){
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            CFErrorRef *error1 = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
            [self copyAddressBook:addressBook];
        }else{
            [ICInfomationView initWithTitle:@"提示" message:@"通讯录权限被关闭，去隐私设置内打开" cancleButtonTitle:@"取消" OtherButtonsArray:@[@"去设置"] clickAtIndex:^(NSInteger buttonAtIndex) {
                if(buttonAtIndex == 1){
                    [PrefsAddressBook openPrivacySetting];
                }
            }];
        }
    }];
}

- (void)copyAddressBook:(ABAddressBookRef)addressBook
{
    NSMutableArray *peopleArr = [NSMutableArray array];
    
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    for ( int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));

        
        ContactModel *model = [ContactModel new];
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取电话Label
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            //获取該Label下的电话值
            NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            
            NSString *telephone = personPhone;
            telephone = [personPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            if(telephone.length > 0){
                model.Tel = telephone;
                break;
            }
        }
        
        
        NSString *name =  @"";
        if(![self isStringEmpty:lastName]){
            name = [NSString stringWithFormat:@"%@%@",name,lastName];
        }
        if(![self isStringEmpty:firstName]){
            name = [NSString stringWithFormat:@"%@%@",name,firstName];
        }
        if(name.length > 0){
            model.NickName = name;
        }else{
            model.NickName = @"??";
        }
        
        [peopleArr addObject:model];
    }
    
    _rowArr = [ContactModel getFriendListDataBy:[NSMutableArray arrayWithArray:peopleArr]];
    _sectionArr = [ContactModel getFriendListSectionBy:[_rowArr mutableCopy]];
    
    [SVProgressHUD dismiss];
    [_mainTableView reloadData];
}

- (void)setupTableView{
    
    _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height + 22.0f)];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:mainCellIdentifer];
    [self.view addSubview:_mainTableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _rowArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_rowArr[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifer];
    
    ContactModel *model=_rowArr[indexPath.section][indexPath.row];
    
    cell.textLabel.text = model.NickName;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _sectionArr;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index - 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 22.0;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //viewforHeader
    id label = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    if (!label) {
        label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:14.5f]];
        [label setTextColor:[UIColor grayColor]];
        [label setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    }
    [label setText:[NSString stringWithFormat:@"  %@",_sectionArr[section]]];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactModel *model=_rowArr[indexPath.section][indexPath.row];
    NSLog(@"%@",model.Tel);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isStringEmpty:(id)obj{
    if (obj==nil || [obj isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([obj isKindOfClass:[NSString class]]) {
        if ([obj length]==0) {
            return YES;
        }
    }
    
    return NO;
    
}

/**
 *  手机号码验证
 *
 *  @param mobileNumbel 传入的手机号码
 *
 *  @return 格式正确返回true  错误 返回fals
 */
- (BOOL)isMobile:(NSString *)mobileNumbel{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189,181(增加)
     */
    NSString * MOBIL = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,181(增加)
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBIL];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNumbel]
         || [regextestcm evaluateWithObject:mobileNumbel]
         || [regextestct evaluateWithObject:mobileNumbel]
         || [regextestcu evaluateWithObject:mobileNumbel])) {
        return YES;
    }
    
    return NO;
}


@end
