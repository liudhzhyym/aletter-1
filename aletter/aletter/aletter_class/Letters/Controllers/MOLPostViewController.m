//
//  MOLPostViewController.m
//  aletter
//
//  Created by xiaolong li on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//
//  发帖类，实现发帖功能

#import "MOLPostViewController.h"
#import "MOLTopicListViewController.h"
//x - ios9
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

// ios9 - x
#import <ContactsUI/ContactsUI.h>
//////

#import "TZImagePickerController.h"
#import <Photos/Photos.h>

#import "MOLHead.h"

#import "StampView.h"
#import "MOLStampSetModel.h"
#import "StampModel.h"

#import "RecordVoiceViewController.h"

#import "MOLPostRequest.h"
#import "MOLLightWeatherModel.h"
#import "MOLStampSetModel.h"

#import "MOLALiyunManager.h"

#import "ToolsHelper.h"
#import "PostModel.h"
#import "MOLLightTopicModel.h"
#import "MOLSendPostViewController.h"
#import "MOLMailDetailViewController.h"
#import "MOLCancleEditViewController.h"
#import "MOLMailboxViewController.h"
#import "MOLTopicRequest.h"

static NSInteger photoCount =3;


@interface MOLPostViewController ()<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate,UIAlertViewDelegate,TZImagePickerControllerDelegate>
{
     dispatch_semaphore_t _semaphore;
     UIBarButtonItem *rightItem;
 
    
}
@property (nonatomic,strong) MOLPostView *postView;

// 相册相关属性
@property (nonatomic,assign) NSInteger maxCountTF;  ///< 照片最大可选张数，设置为1即为单选模式
@property (nonatomic,assign) NSInteger columnNumberTF; ///<照片每行显示多少张
@property (nonatomic,strong) NSMutableArray *selectedPhotos;  ///< 表示选中图片资源
@property (nonatomic,strong) NSMutableArray *selectedAssets; ///<表示图片相关资源
@property (nonatomic,assign) BOOL isSelectOriginalPhoto;  ///< yes 表示是原图
@property (nonatomic,strong) StampView *stampView;
@property (nonatomic,strong) NSMutableArray *stampArr;
@property (nonatomic,strong) StampModel *stampDto;

@property (nonatomic, strong) NSIndexPath *recordOldIndex; //用于记录之前选中邮票标识
@property (nonatomic, strong) NSIndexPath *recordNewIndex; //用于记录当前选中邮票标识

@property (nonatomic, strong) MOLLightWeatherModel *weatherDto; //天气model
@property (nonatomic, copy) NSString *phoneNumber; //电话号
@property (nonatomic, copy) NSString *content; //话题
@property (nonatomic, copy) NSString *interaction; //互动 1默认互动 0不允许互动
@property (nonatomic, strong) NSMutableArray *photosUrl; //获取到图片相关数据
@property (nonatomic, strong) MOLStampSetModel *stampSetDto;
@property (nonatomic, strong) MOLLightTopicModel *topicDto; //用于记录话题数据
@property (nonatomic, strong) PostModel *postDto;
@property (nonatomic, strong) MOLStoryModel *postStoryDto;

@end

@implementation MOLPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MOLMailboxViewController class]]) {
            [obj removeFromParentViewController];
        }
    }];
   self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initData];
    [self layoutNavigation];
    [self layoutSubViewS];
    
    if (self.behaviorType !=PostBehaviorUpdateType) {
        [self getWeatherNetworkData];
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.postView molPostView:self.postView date:[NSString stringWithFormat:@"%@年%@月%@日,%@",self.weatherDto.year?self.weatherDto.year:@"2018",self.weatherDto.month?self.weatherDto.month:@"",self.weatherDto.day?self.weatherDto.day:@"",self.weatherDto.week?self.weatherDto.week:@""] weather:[NSString stringWithFormat:@"%@",self.weatherDto.weather?self.weatherDto.weather:@""]];
        });
    }
    
    [self getStampNetworkData];

    [self registerForObserver];
    
     if (self.behaviorType ==PostBehaviorUpdateType) { //修改帖子
     
         //处理获取照片数据
         [self.postView molPostView:self.postView selectedPhotos:self.selectedPhotos selectedAssets:self.selectedAssets isSelectOriginalPhoto:self.isSelectOriginalPhoto];
         
     }
    
    
    
//    //    UITapGestureRecognizer *gesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardEvent:)];
//    //    [self.view addGestureRecognizer:gesture];

    [self getAddTopicNetworkData];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_postView && _postView.postTextView.resignFirstResponder) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MOLPostViewNotification" object:@""];
    }
}

// 获取添加话题列表---目的是实现添加话题展不展示
- (void)getAddTopicNetworkData{
    //获取数据
    MOLTopicRequest *r = [[MOLTopicRequest alloc] initRequest_topicListWithParameter:nil parameterId:self.mailModel.channelId];
    __weak __typeof(self) weakSelf = self;
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            if ([request.responseObject[@"resBody"] isKindOfClass:[NSArray class]]) {
                NSArray *arr =(NSArray *)request.responseObject[@"resBody"];
                if (arr.count>0) {
                    [weakSelf.postView molPostView:weakSelf.postView showTopic:NO];
                }
            }
          
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

#pragma mark -
#pragma mark 网络请求数据
- (void)getWeatherNetworkData{
    // 发送请求
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.location) {
        //纬度：经度
        [dic setObject:[NSString stringWithFormat:@"%lf:%lf",self.location.coordinate.latitude?self.location.coordinate.latitude:0,self.location.coordinate.longitude?self.location.coordinate.longitude:0] forKey:@"location"];
    }
    else{
        [dic setObject:@"" forKey:@"location"];
    }
    __weak __typeof(self) weakSelf = self;
    [[[MOLPostRequest alloc] initRequest_weatherWithParameter:dic] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            
            if (responseModel) {
                
                if (!weakSelf.weatherDto) {
                    weakSelf.weatherDto =[MOLLightWeatherModel new];
                }
                
                dispatch_semaphore_wait(self->_semaphore, DISPATCH_TIME_FOREVER);
                weakSelf.weatherDto =(MOLLightWeatherModel *)responseModel;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.postView molPostView:weakSelf.postView date:[NSString stringWithFormat:@"%@年%@月%@日,%@",weakSelf.weatherDto.year?weakSelf.weatherDto.year:@"2018",weakSelf.weatherDto.month?weakSelf.weatherDto.month:@"",weakSelf.weatherDto.day?weakSelf.weatherDto.day:@"",weakSelf.weatherDto.week?weakSelf.weatherDto.week:@""] weather:[NSString stringWithFormat:@"%@",weakSelf.weatherDto.weather?weakSelf.weatherDto.weather:@""]];
                });
                dispatch_semaphore_signal(self->_semaphore);
            }
            
        }else{
//            [MOLToast toast_showWithWarning:YES title:message];
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {

    }];
    
}

- (void)getStampNetworkData{
    // 发送请求
    __weak __typeof(self) weakSelf = self;
    [[[MOLPostRequest alloc] initRequest_StampWithParameter:nil] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            
            if (responseModel) {
                if (!weakSelf.stampSetDto) {
                    weakSelf.stampSetDto =[MOLStampSetModel new];
                }
                dispatch_semaphore_wait(self->_semaphore, DISPATCH_TIME_FOREVER);
                 weakSelf.stampSetDto =(MOLStampSetModel *)responseModel;
    
                if (weakSelf.stampSetDto.stampList) {
                    weakSelf.stampArr =[NSMutableArray arrayWithArray:weakSelf.stampSetDto.stampList];
                }
                if (weakSelf.stampArr.count>0) {
                    StampModel *obj =[StampModel new];
                    if (weakSelf.behaviorType ==PostBehaviorUpdateType) {//修改帖子
                        
                      __block  BOOL isExist=NO;
                        [weakSelf.stampArr enumerateObjectsUsingBlock:^(StampModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.stampId isEqualToString: weakSelf.stampDto.stampId]) {
                                isExist =YES;
                                obj.isSelectStatus =YES;
                                weakSelf.stampDto =obj;
                                
                                //初始化邮票选中标识
                                self.recordOldIndex =[NSIndexPath indexPathForRow:0 inSection:idx];
                                self.recordNewIndex =[NSIndexPath indexPathForRow:0 inSection:idx];
                                //此时应该直接跳出快速遍历
                            }
                        }];
                        
                        if (!isExist) {
                            obj = weakSelf.stampArr[0];
                            obj.isSelectStatus =YES;
                            weakSelf.stampDto =obj;
                            [weakSelf.stampArr replaceObjectAtIndex:0 withObject:obj];
                        }
                        
                    }else{
                        obj = weakSelf.stampArr[0];
                        obj.isSelectStatus =YES;
                        weakSelf.stampDto =obj;
                        [weakSelf.stampArr replaceObjectAtIndex:0 withObject:obj];
                    }
                    
                   
                }
                dispatch_semaphore_signal(self->_semaphore);
            }
            
        }else{
            [MOLToast toast_showWithWarning:YES title:message];
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];

}


#pragma mark - Notifications

- (void)registerForObserver {
    // 邮票消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stampViewNotification:) name:@"StampViewNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stampRecordNewIndex:) name:@"StampViewSelectItemNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(molPostViewTextFieldDidChange:) name:@"MOLPostViewTextFieldDidChange" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(molPostViewTextViewDidChange:) name:@"MOLPostViewTextViewDidChange" object:nil];
    
}

- (void)stampViewNotification:(NSNotification *)notif{
    if (notif.object) {
        self.stampDto =(StampModel *)notif.object;
    }
}

- (void)stampRecordNewIndex:(NSNotification *)notif{
    
    if (notif.object) {
        NSIndexPath *redord =notif.object;
        self.recordNewIndex =redord;
        
        if (self.stampArr.count>self.recordOldIndex.row) {
            StampModel *model =[StampModel new];
            model =self.stampArr[self.recordOldIndex.row];
            model.isSelectStatus =NO;
            [self.stampArr replaceObjectAtIndex:self.recordOldIndex.row withObject:model];
            
            model =self.stampArr[self.recordNewIndex.row];
            model.isSelectStatus =YES;
            [self.stampArr replaceObjectAtIndex:self.recordNewIndex.row withObject:model];
            
            self.recordOldIndex =self.recordNewIndex;
        }
    }
}


- (void)initData{
    _semaphore = dispatch_semaphore_create(1);
    NSLog(@"loc ->%lf lc->%lf",self.location.coordinate.longitude,self.location.coordinate.latitude);
    
    self.stampDto =[StampModel new];
    self.stampArr =[NSMutableArray new];
    self.weatherDto =[MOLLightWeatherModel new];
    self.postDto =[PostModel new];
    self.topicDto =[MOLLightTopicModel new];
    self.phoneNumber =[NSString new];
    self.content =[NSString new];
    self.selectedPhotos =[NSMutableArray new];
    self.selectedAssets =[NSMutableArray new];
    self.photosUrl =[NSMutableArray new];
    
    self.maxCountTF =photoCount;
    self.columnNumberTF =4;
    self.recordOldIndex =[NSIndexPath indexPathForRow:0 inSection:0];
    self.recordNewIndex =[NSIndexPath indexPathForRow:0 inSection:0];
    
    self.postStoryDto =[MOLStoryModel new];
    self.postStoryDto =self.storyModel;
    
    if (self.behaviorType ==PostBehaviorUpdateType) { //修改帖子
        self.mailModel =[MOLMailModel new];
        self.photosUrl =[NSMutableArray new];
        if (self.storyModel) {
            if (self.storyModel.channelVO) {
                self.mailModel =self.storyModel.channelVO;
            }
            
            if (self.storyModel.stampVO) {
                self.stampDto.stampId =self.storyModel.stampVO.stampId;
                self.stampDto.lightImage =self.storyModel.stampVO.stampImg;
                self.stampDto.isAuthority=@"1";
            }else{
               
            }
            
            if (self.storyModel.weatherInfo) {
                self.weatherDto =self.storyModel.weatherInfo;
            }
            
            if (self.storyModel.topicVO) {
                self.topicDto =self.storyModel.topicVO;
            }
            
            if (self.storyModel.chatOpen) {
                self.interaction =@"1";
            }
            else{
                self.interaction =@"0";
            }
            
            if (self.storyModel.content) {
                self.content =self.storyModel.content_original;
            }
            
            if (self.storyModel.photos && self.storyModel.photos.count>0) {
                self.photosUrl =[NSMutableArray arrayWithArray:self.storyModel.photos];
                
                [self.storyModel.photos enumerateObjectsUsingBlock:^(MOLLightPhotoModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    UIImage * result;
                    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:obj.src]];
                    result = [UIImage imageWithData:data];
                    [self.selectedPhotos addObject: result];
                }];
            }
        }
        
        
    }else{
        self.interaction =@"1"; //默认互动
    }
    
    if (self.fromviewController==1) {
        self.topicDto =self.ttTopicDto;
    }
    
    
    NSLog(@"%@---%@",self.mailModel,self.mailModel);
}

- (void)keyBoardEvent:(UIGestureRecognizer *)sender{
    [self.postView keyboardEvent];
}

- (void)layoutNavigation{
    rightItem = [UIBarButtonItem mol_barButtonItemWithTitleName:@"完成" targat:self action:@selector(completedEvent:)];
    rightItem.tintColor = [HEX_COLOR(0xffffff) colorWithAlphaComponent:0.7];
    
    if (self.behaviorType !=PostBehaviorUpdateType) { //修改帖子
        [rightItem setEnabled:NO];
    }
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)layoutSubViewS{
    
    if (self.mailModel) {
        
        if (self.mailModel.isPublish ==1 ||self.mailModel.isPublish ==2) {
            [self.view addSubview:self.postView];
        }
        
        if (self.mailModel.channelId.length>0 && self.mailModel.channelId.integerValue ==520) { //暗恋类型
            if (self.mailModel.isPublish ==1) { //音频
                [self.postView molPostView:self.postView viewPostBusinessType:PostBusinessUnrequitedLoveType viewPostContentType:PostContentAudioAndWordsType];
            }
            else if(self.mailModel.isPublish ==2){ //图文
                [self.postView molPostView:self.postView viewPostBusinessType:PostBusinessUnrequitedLoveType viewPostContentType:PostContentImageAndWordsType];
            }
            
        }else{//通用类型
            if (self.mailModel.isPublish ==1) { //音频
                [self.postView molPostView:self.postView viewPostBusinessType:PostBusinessGeneralType viewPostContentType:PostContentAudioAndWordsType];
            }
            else if(self.mailModel.isPublish ==2){ //图文
                [self.postView molPostView:self.postView viewPostBusinessType:PostBusinessGeneralType viewPostContentType:PostContentImageAndWordsType];
            }
        }
        
    }else{
        self.mailModel =[MOLMailModel new];
        [self.postView molPostView:self.postView viewPostBusinessType:PostBusinessGeneralType viewPostContentType:PostContentImageAndWordsType];
    }
    
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (self.mailModel.isPublish ==1 ||self.mailModel.isPublish ==2) {
        __weak __typeof(self) weakSelf = self;
        [self.postView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.bottom.mas_equalTo(weakSelf.view);
            
        }];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.postView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.postView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.postView.layer.mask = maskLayer;
    }
}

#pragma mark-
#pragma mark UI懒加载
- (MOLPostView *)postView{
    if (!_postView) {
        _postView =[MOLPostView new];
        [_postView setBackgroundColor: [UIColor whiteColor]];
        _postView.behaviorType =PostBehaviorUpdateType;
        _postView.mailModel =self.mailModel;
        _postView.storyModel =self.storyModel;
        _postView.fromviewController =self.fromviewController;
        _postView.ttTopicDto =self.topicDto;
        __weak __typeof(self) weakSelf = self;
        _postView.MOLPostViewAddTopicBlock = ^{
            
            MOLTopicListViewController *molTopicListView=[MOLTopicListViewController new];
            molTopicListView.isChooseTopic=YES;
            molTopicListView.channelId =weakSelf.mailModel.channelId;
            molTopicListView.chooseBlock = ^(MOLLightTopicModel *model) {
                if (model) {
                    weakSelf.topicDto =model;
                    [weakSelf.postView molPostView:weakSelf.postView topicData:model];
                }
            };
//            [weakSelf.navigationController pushViewController:molTopicListView animated:YES];
            [weakSelf presentViewController:molTopicListView animated:YES completion:nil];
        };
        
        _postView.molPostViewDeleteAddTopicBlock = ^{
            if (weakSelf.topicDto) {
                weakSelf.topicDto.topicName=@"";
                weakSelf.topicDto.topicId=@"";
            }
            
        };
        
        _postView.molPostViewDeleteAddTopicBlock = ^{
            NSLog(@"初始化话题数据事件响应");
        };
        
        _postView.molPostViewAddressBookBlock = ^{
            NSLog(@"打开通讯录事件触发");
            if (@available(iOS 9.0, *)) {
                CNContactStore * contactStore = [[CNContactStore alloc]init];
                if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
                    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * __nullable error) {
                        if (granted) {//请求成功
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //获取通讯录数据
                                NSLog(@"获取通讯录成功");
                                // 1. 创建选择联系人控制器
                                CNContactPickerViewController *pickerVC = [[CNContactPickerViewController alloc] init];
                                pickerVC.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
                                
                                // 2. 设置代理
                                pickerVC.delegate = weakSelf;
                                
                                // 3. 弹出控制器
                                [weakSelf presentViewController:pickerVC animated:YES completion:nil];
                                
                            });
                        }
                    }];
                    
                } else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
                    //请求通讯录数据
                    NSLog(@"已经有权限了");
                    // 1. 创建选择联系人控制器
                    CNContactPickerViewController *pickerVC = [[CNContactPickerViewController alloc] init];
                     pickerVC.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
                    // 2. 设置代理
                    pickerVC.delegate = weakSelf;
                    
                    // 3. 弹出控制器
                    [weakSelf presentViewController:pickerVC animated:YES completion:nil];
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在“设置-隐私-通讯录”选项中，允许使用您的手机通讯录。" delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
                        
                        [alert show];
                    });
                }
                
//                CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
//                contactPicker.delegate = weakSelf;
//                contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
//                 [weakSelf presentViewController:contactPicker animated:YES completion:nil];
                
            } else {
                
                //请求权限
                if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
                    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
                    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                        if (granted) {//请求成功
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //获取通讯录数据
                                NSLog(@"获取通讯录成功");
                                ABPeoplePickerNavigationController *peoplePickController = [[ABPeoplePickerNavigationController alloc] init];
                                peoplePickController.peoplePickerDelegate = weakSelf;
                                [weakSelf presentViewController:peoplePickController animated:YES completion:^{
                                    
                                }];
                            });
                        }
                    });
                    if (addressBookRef) {
                        CFRelease(addressBookRef);
                        addressBookRef = nil;
                    }
                }
                //已经有了权限
                else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
                    //请求通讯录数据
                    NSLog(@"已经有权限了");
                    ABPeoplePickerNavigationController *peoplePickController = [[ABPeoplePickerNavigationController alloc] init];
                    peoplePickController.peoplePickerDelegate = weakSelf;
                    [weakSelf presentViewController:peoplePickController animated:YES completion:^{
                    }];
                }
                //提示用户开启权限
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在“设置-隐私-通讯录”选项中，允许使用您的手机通讯录。" delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
                        
                        [alert show];
                    });
                }
                
            }
        };
        
        //跳转到相册
        _postView.molPostViewImageButtonBlock = ^(NSIndexPath *indexPath){
            
            if (weakSelf.selectedPhotos.count>=3) {
                // 跳转到预览页面
//                TZImagePickerController *imagePickerVc =[[TZImagePickerController alloc] initWithSelectedAssets:weakSelf.selectedAssets selectedPhotos:weakSelf.selectedPhotos index:indexPath.row isOnlyPreview:YES];
//                [weakSelf presentViewController:imagePickerVc animated:YES completion:nil];
                
                HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
                browser.isNeedLandscape = NO;
                browser.currentImageIndex = (int)indexPath.row;
                browser.imageArray = weakSelf.selectedPhotos;
                browser.isUIImageObject =YES;
                [browser show];
                
                return ;
            }else{
                if (weakSelf.selectedPhotos.count>0 && indexPath.item<weakSelf.selectedPhotos.count) {
                    // 跳转到预览页面
//                    TZImagePickerController *imagePickerVc =[[TZImagePickerController alloc] initWithSelectedAssets:weakSelf.selectedAssets selectedPhotos:weakSelf.selectedPhotos index:indexPath.row isOnlyPreview:YES];
//                    [weakSelf presentViewController:imagePickerVc animated:YES completion:nil];
                    
                    HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
                    browser.isNeedLandscape = NO;
                    browser.currentImageIndex = (int)indexPath.row;
                    browser.imageArray = weakSelf.selectedPhotos;
                    browser.isUIImageObject=YES;
                    [browser show];
                    
                    return ;
                }
            }
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                switch (status) {
                    case PHAuthorizationStatusNotDetermined:
                    case PHAuthorizationStatusRestricted:
                    case PHAuthorizationStatusDenied:
                    {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在手机系统“设置-隐私-照片”选项中，允许访问您的相册。" delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
                            
                            [alert show];
                            
                        });
                        
                    }
                        break;
                        
                    case PHAuthorizationStatusAuthorized:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf pushTZImagePickerController];
                        });
                        
                    }
                        break;
                }
            }];
        };
        
        
        _postView.molPostViewMailboxButtonBlock = ^{
            NSLog(@"邮票事件处理");
            if (weakSelf.stampView) {
                [weakSelf.stampView removeFromSuperview];
                weakSelf.stampView =nil;
            }
            weakSelf.stampView =[[StampView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT)];
            [weakSelf.stampView showStampView:weakSelf.stampArr oldSelect:weakSelf.recordOldIndex];
            
        };
        
        _postView.molPostViewVoiceButtonBlock = ^(NSIndexPath *indexPath) {
            RecordVoiceViewController *recordVoice =[RecordVoiceViewController new];
            recordVoice.MRecordVoiceViewControllerVoiceBlock = ^(NSInteger voiceSec, NSString *voiceFile) {
                weakSelf.postDto.time =[NSString stringWithFormat:@"%ld",voiceSec>0?voiceSec:0];
                weakSelf.postDto.audioUrl =[NSString stringWithFormat:@"%@",voiceFile?voiceFile:@""];
                [weakSelf.postView molPostView:weakSelf.postView fileUrl:weakSelf.postDto.audioUrl sec:weakSelf.postDto.time.integerValue];
            };
            [weakSelf.navigationController presentViewController:recordVoice animated:YES completion:nil];
        };
        
        _postView.molPostViewInteractiveBlock = ^(UIButton *sender) {
            if (sender.isSelected) {
                weakSelf.interaction=@"1";
            }else{
                weakSelf.interaction=@"0";
            }
        };
        
    }
    return _postView;
}



#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    if (self.maxCountTF <= 0) {
        return;
    }
    
    self.maxCountTF =photoCount-self.selectedPhotos.count;
    
    NSLog(@"--%ld--",self.maxCountTF);
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxCountTF columnNumber:self.columnNumberTF delegate:self pushPhotoPickerVc:YES];
    [imagePickerVc setNaviBgColor: [UIColor clearColor]];
    
    
    //[imagePickerVc setAllowTakePicture:NO];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


#pragma mark - alertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFStringRef telValue = ABMultiValueCopyValueAtIndex(valuesRef,0);
    //  self.label.text = (__bridge NSString *)telValue;
    [self.postView molPostView:self.postView addressBookData:(__bridge NSString *)telValue];
    
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty API_AVAILABLE(ios(9.0)){
    
    if (@available(iOS 9.0, *)) {
        CNPhoneNumber *phoneNumber = (CNPhoneNumber *)contactProperty.value;
        [self dismissViewControllerAnimated:YES completion:^{
            
            if(![phoneNumber isKindOfClass:[NSString class]]){
             [self.postView molPostView:self.postView addressBookData:phoneNumber.stringValue];
            }
 
        }];
    }
    
    
}

#pragma mark - TZImagePickerControllerDelegate
// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    [_selectedPhotos addObjectsFromArray:photos];
    [_selectedAssets addObjectsFromArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;

    //处理获取照片数据
    [self.postView molPostView:self.postView selectedPhotos:self.selectedPhotos selectedAssets:self.selectedAssets isSelectOriginalPhoto:self.isSelectOriginalPhoto];
}



#pragma mark - 按钮的点击
- (void)completedEvent:(UIButton *)sender
{
    [MobClick event:@"_c_finish_editing"];
    [sender setEnabled:NO];
    NSLog(@"触发完成事件");
    
    if(!self.postDto){
        self.postDto =[PostModel new];
    }
    
    if(self.mailModel){//频道数据
        self.postDto.mailModel =self.mailModel;
    }
    
    if(self.weatherDto){ //天气数据
        self.postDto.weatherModel =self.weatherDto;
    }
    
    if (self.stampDto) {//邮票数据
        self.postDto.stampModel =self.stampDto;
    }
    
    if(self.interaction){//互动 1 不允许互动 0
        self.postDto.chatOpen =self.interaction;
    }else{
        self.postDto.chatOpen =@"1";
    }
    
    
    if(self.topicDto){ //添加话题
        self.postDto.topicModel =self.topicDto;
    }
    
    
    
    if (self.photosUrl) {//图片数据
        
    }
    
    if (self.postDto.audioUrl) {//音频数据

    }
    
    if(self.content){ //添加话题
        self.postDto.content =self.content;
    }
    
    if(self.location){ //位置信息
        self.postDto.location =self.location;
    }
    
    if (self.mailModel.isPublish ==1) { //音频
        self.postDto.storyType =@"0";
    }
    else if(self.mailModel.isPublish ==2){ //图文
        self.postDto.storyType =@"1";
    }
    
    if (self.phoneNumber) {
        self.postDto.toPhoneId =self.phoneNumber;
    }
    
    if (self.behaviorType ==PostBehaviorUpdateType) {
        if (self.storyModel.storyId) {
            self.postDto.storyId =self.storyModel.storyId;
        }
    }
    
    __weak __typeof(self) weakSelf = self;
    // 图片数据处理
    if (self.selectedPhotos.count>0) {
        //整理发送数据
        [[MOLALiyunManager shareALiyunManager] aLiyun_uploadImages:self.selectedPhotos complete:^(NSArray<NSDictionary *> *names) {
            weakSelf.postDto.photos =names;
            [self storePrivateEnvelopeUploadingDataToNet:sender];
        }];
        
    }else{
        
        [self storePrivateEnvelopeUploadingDataToNet:sender];
        
    }
    
}

- (void)storePrivateEnvelopeUploadingDataToNet:(UIButton *)sender{ //0 私信 2 公开
    // 发送请求
    
     __weak __typeof(self) weakSelf = self;
    NSMutableDictionary *dic =[NSMutableDictionary new];
    
    if (self.behaviorType!=PostBehaviorUpdateType) { //修改帖子
       [dic setObject:@"0" forKey:@"privateSign"];
    }
    
    [dic setObject:self.postDto.storyType?self.postDto.storyType:@"0" forKey:@"storyType"];
    [dic setObject:self.postDto.content?self.postDto.content:@"" forKey:@"content"];
    [dic setObject:self.postDto.mailModel.channelId?self.postDto.mailModel.channelId:@"" forKey:@"channelId"];
    [dic setObject:self.postDto.chatOpen?self.postDto.chatOpen:@"1" forKey:@"chatOpen"];
    [dic setObject:[NSString stringWithFormat:@"%lf",self.postDto.location.coordinate.latitude?self.postDto.location.coordinate.latitude:0] forKey:@"lat"];
    [dic setObject:[NSString stringWithFormat:@"%lf",self.postDto.location.coordinate.longitude?self.postDto.location.coordinate.longitude:0] forKey:@"lgt"];
    [dic setObject:self.postDto.audioUrl?self.postDto.audioUrl:@"" forKey:@"audioUrl"];
    [dic setObject:@"" forKey:@"name"];
    [dic setObject:self.postDto.photos?self.postDto.photos:[NSArray array] forKey:@"photos"];
    [dic setObject:self.postDto.stampModel.lightImage?self.postDto.stampModel.lightImage:@"" forKey:@"stampImg"];
    [dic setObject:self.postDto.time?self.postDto.time:@"0" forKey:@"time"];
    [dic setObject:self.postDto.toPhoneId?self.postDto.toPhoneId:@"" forKey:@"toPhoneId"];
    [dic setObject:@"" forKey:@"toUserId"];
    [dic setObject:self.postDto.topicModel.topicId?self.postDto.topicModel.topicId:@"" forKey:@"topicId"];
    [dic setObject:self.postDto.weatherModel.weather?self.postDto.weatherModel.weather:@"" forKey:@"weather"];
    
    MOLPostRequest *r;
    if (weakSelf.behaviorType==PostBehaviorUpdateType) { //修改帖子
        r = [[MOLPostRequest alloc] initRequest_UpdateStoryWithParameter:dic parameterId:self.postDto.storyId?self.postDto.storyId:@""];
    }else{
        r = [[MOLPostRequest alloc] initRequest_privateEnvelopeWithParameter:dic];
    }
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            
            if (weakSelf.behaviorType==PostBehaviorUpdateType) { //修改帖子
                
                MOLStoryModel *model =[MOLStoryModel new];
                model =(MOLStoryModel *)responseModel;
                weakSelf.molPostViewControllerBlock(model);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSString  *storyId= [NSString stringWithFormat:@"%ld",[[[request.responseObject mol_jsonDict:@"resBody"] objectForKey:@"storyId"] integerValue]];
                weakSelf.postDto.storyId=storyId;
                MOLSendPostViewController *sendPostView =[MOLSendPostViewController new];
                sendPostView.postModel =weakSelf.postDto;
                [weakSelf.navigationController pushViewController:sendPostView animated:YES];
            }
            
        }else{
            [MOLToast toast_showWithWarning:YES title:message];
        }
        [sender setEnabled:YES];
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        [sender setEnabled:YES];
    }];
    
}

- (void)molPostViewTextFieldDidChange:(NSNotification *)notif{
    if (notif.object && [notif.object isKindOfClass:[NSString class]]) {
        NSString *str =(NSString *)notif.object;
        if (str && str.length>0) {
            self.phoneNumber =str;
        }
    }
}

- (void)molPostViewTextViewDidChange:(NSNotification *)notif{
    if (notif.object && [notif.object isKindOfClass:[NSString class]]) {
        NSString *str =(NSString *)notif.object;
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (str && str.length>0) {
            self.content =str;
            rightItem.tintColor = [HEX_COLOR(0xffffff) colorWithAlphaComponent:1.0];
            [rightItem setEnabled:YES];
        }else{
            rightItem.tintColor = [HEX_COLOR(0xffffff) colorWithAlphaComponent:0.7];
            [rightItem setEnabled:NO];
        }
    }
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
#if    !OS_OBJECT_USE_OBJC
    dispatch_release(_semaphore);
#endif
    
}

- (void)leftBackAction{
    
    
    if ((self.content && self.content.length>0) || (self.postDto.audioUrl && self.postDto.audioUrl.length>0) || (self.selectedPhotos && self.selectedPhotos.count>0)) {
        
        MOLCancleEditViewController *vc = [[MOLCancleEditViewController alloc] init];
        @weakify(self);
        vc.cancleEditBlock = ^{
            @strongify(self);
            
            [self dismissViewController];
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
    else{
        [self dismissViewController];
    }
}

- (void)dismissViewController
{
    [self.navigationController popViewControllerAnimated:YES];
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
