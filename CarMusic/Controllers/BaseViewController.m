//
//  BaseViewController.m
//  CarClub
//
//  Created by DarrenKong on 15/7/7.
//  Copyright © 2015年 wacosoft. All rights reserved.
//

#import "BaseViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "PayApi.h"
#import "TicketItem.h"
#import "DownloadItem.h"
#import "DownloadManager.h"
@interface BaseViewController ()
{
    UINavigationBar  *_naviBar;
    PanxiaofenStatus _panxiaofenStatus;
}

@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int numberOfPage;
@property (nonatomic, assign) VCStatus       vcStatus;

@end

@implementation BaseViewController
@dynamic naviBar;

#pragma mark -- life cycle

-(UIView*)view
{
    return _enableContentScroll ? self.baseView : [super view];
}

-(UIScrollView*)baseView
{
    if (_baseView == nil) {
        _baseView = [[BaseView alloc] initWithFrame:super.view.bounds];
        _baseView.contentSize = CGSizeMake(super.view.width, super.view.height+1);
        _baseView.showsVerticalScrollIndicator = NO;
        _baseView.backgroundColor = [UIColor clearColor];
        [super.view addSubview:_baseView];
    }
    return _baseView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setExtendedLayoutIncludesOpaqueBars:YES];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.vcStatus = VCStatusInit;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshItemStatus:) name:FXDownloadItemCompleted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning)name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

#pragma mark - refreshSongStatus
- (void)refreshItemStatus:(NSNotification *)notification
{

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.vcStatus = VCStatusDidLoad;
    self.fd_prefersNavigationBarHidden = YES;
    self.themeColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIViewController *_rootController = [[self.navigationController viewControllers] objectAtIndex:0];
//    if (![_rootController isEqual:self])
//    {
//        [self setNavBarBarItem:@"返回" target:self action:@selector(back:) atRight:NO];
//    }
    [self creatWidgets];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.vcStatus = VCStatusAppear;
    if ( _freshWhenAppear && _status != DLStatusLoading) {
        [self loadData];
    }
    
    if (IS_IOS7)
    {
        self.naviBar.barTintColor = _themeColor;
    }else
    {
        self.naviBar.tintColor = _themeColor;
    }
    [MobClick beginLogPageView:self.title];
    NSLog(@"%@",self.title);
//    if ([self.navigationController.navigationBar isEqual:self.naviBar]) {
//        self.navigationController.navigationBarHidden = NO;
//    }else{
//        self.navigationController.navigationBarHidden = YES;
//    }
    
//    if (self.navigationController.viewControllers.count != 1) {
//        UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"record_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
//        self.navigationItem.leftBarButtonItem = back;
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];//解决搜狗键盘弹出，未及时关闭，从而导致UITextFIeld光标有误
    SethActivityIndicator_Stop();
    {//防止验证码串门
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    //        [standardUserDefaults setObject:result forKey:kMY_AUTH_CODE];
    [standardUserDefaults setObject:@"" forKey:kMY_AUTH_CODE];
    [standardUserDefaults setObject:@"" forKey:kMY_AUTH_PHONENUM];
    // 立刻保存信息
    [standardUserDefaults synchronize];
    }
    [MobClick endLogPageView:self.title];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.vcStatus = VCStatusDisAppear;
    if ( _status == DLStatusLoading ) {
        self.status = DLStatusFaild;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)showAlert:(NSString *)str andDisAppearAfterDelay:(float)time
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = str;
    [self.view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:time];
}

-(void)setStatus:(DLStatus)status
{
    _status = status;
    switch (_status) {
        case DLStatusLoading:
//            net_activity_indicator_start(INetActivityType_USER);
            break;
        default:
//            net_activity_indicator_stop(INetActivityType_USER);
            break;
    }
}

- (void)creatWidgets
{
    NSLog(@"%@ 需要实现%s", [self class], __func__);
}

-(void)loadData
{
    NSLog(@"%@ 需要实现%s", [self class], __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavBarBarItem:(NSString *)aImageName target:(id)aTarget action:(SEL)aAction atRight:(BOOL)aRight
{
    UIImage *_image = [UIImage imageNamed:aImageName];
    UIButton *_barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_barButton setImage:_image forState:UIControlStateNormal];
    _barButton.frame = CGRectMake(0, 0,_image.size.width, _image.size.height);
    [_barButton addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *_buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_barButton];
    if (aRight) {
        self.navigationItem.rightBarButtonItem = _buttonItem;
    }else
    {
        if ([aImageName isEqualToString:@"record_back"]) {
            self.navigationItem.backBarButtonItem = _buttonItem;
        }else{
            self.navigationItem.leftBarButtonItem = _buttonItem;
        }
    }
}

- (void)setNavBarBarItemWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)aAction atRight:(BOOL)aRight
{
    UIButton *_barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _barButton.frame = CGRectMake(0, 0,50, 30);
    [_barButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_barButton addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
    [_barButton setTitle:aTitle forState:UIControlStateNormal];
    
    UIBarButtonItem *_buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_barButton];
    if (aRight) {
        self.navigationItem.rightBarButtonItem = _buttonItem;
    }else
    {
        if ([aTitle isEqualToString:@"返回"]) {
            self.navigationItem.backBarButtonItem = _buttonItem;
        }else{
            self.navigationItem.leftBarButtonItem = _buttonItem;
        }
    }
}

- (void)pushViewController:(BaseViewController *)controller
{
    controller.hidesBottomBarWhenPushed = YES;
    self.navigationController.navigationBar.hidden = NO;
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(UINavigationBar*)naviBar
{
    return _naviBar ? _naviBar : self.navigationController.navigationBar;
}

-(void)setNaviBar:(UINavigationBar *)navigationBar
{
    _naviBar = nil;
    [_naviBar removeFromSuperview];
    _naviBar = navigationBar;
    if (_naviBar) {
        [self.view addSubview:_naviBar];
    }
}

- (MyAVPlayer *)miniPlayer
{
    return [DataCenter shareInstance].musicPlayer;
}

- (void)setIsShowPlayer:(BOOL)isShowPlayer
{
    if (isShowPlayer) {
        if (![DataCenter shareInstance].musicPlayer)
        {
            NSArray *array = [NSArray array];
            NSDictionary *g_audio = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"singleton", @"1", @"identifier", @"true", @"visible", @"true", @"expand", @"true", @"autoPlay", @"1", @"style", @"true", @"isGlobalChang", array, @"content", nil];
            Audio *tempAudio = [[Audio alloc] initWithGlobalJSON:g_audio];
            MyAVPlayer *player = [[MyAVPlayer alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-P_Styte1H, SCREEN_WIDTH, P_Styte1H)];
            [[[UIApplication sharedApplication].delegate window] insertSubview:player aboveSubview:((UINavigationController*)[[UIApplication sharedApplication].delegate window].rootViewController).view];
            [DataCenter shareInstance].musicPlayer = player;
            [player setPlayerMessage:tempAudio];
        }
    }
    [self layoutSubViews];
}

- (void)layoutSubViews
{
    [[self miniPlayer] playerPosition:_bottomOffset];
    [self.view addSubview:[self miniPlayer]];
}

- (BOOL)isLogin
{
    //[UserManager shareInstance].uid = [[NSUserDefaults standardUserDefaults] objectForKey:@""];
    if ([[UserManager shareInstance].currentUser.phone length] >0 &&![[UserManager shareInstance].currentUser.phone isEqualToString:@"0"]) {
        
        return YES;
    }
    return NO;
}

- (void)showLoginVC
{
//    UIViewController *tagart = ([[UIApplication sharedApplication].delegate window].rootViewController);
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).loginViewController == nil)
    {
        Class cls = NSClassFromString(@"LoginViewController");
        BaseViewController* vc = [[cls alloc] init];
        [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:^{
            
        }];
    }
}

- (void)homeBack:(id)sender
{
    if (self.mm_drawerController.openSide == MMDrawerSideNone) 
    {
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    else
    {
        [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            
        }];
    }
}

- (void)back:(id)sender
{
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidCurrentView
{
    NSLog(@"加载为当前视图 = %@",self.title);
    _isRefresh = true;
    _index = 0;
}

/**
 *   Judge item  检测是否有券的通用入口  yes 是mv
 */
- (void)judgeItem:(StandarItem *)contentId isVideo:(BOOL)abool
{
    contentId.isFull = @"0"; //不能听完整的歌曲
    if (![contentId.isFree isEqualToString:@"0"]) {
        if ([self isLogin]){
            [self downloadItem:contentId isVideo:abool callBack:^(PanxiaofenStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PanxiaofenStatusDownLoad) { //能听完整的歌曲
                        contentId.isFull = @"1";
                        [self playerMusic:contentId];
                    }else if(status == PanxiaofenStatusNoneTicket){//只能试听三十秒
                        [self playerMusic:contentId];
                    }else{
                        [self playerMusic:contentId];
                    }
                });
            }];
        }else{
            [self playerMusic:contentId];
        }
    }else{ //是免费
        
               [self playerMusic:contentId];
    }
   
}

/**
 *   downloadItem
 */
- (void)downloadItem:(StandarItem *)item isVideo:(BOOL)abool callBack:(void(^)(PanxiaofenStatus status))call
{
    if (![self isLogin]) {
        _panxiaofenStatus = PanxiaofenStatusNoLogin;
        call(_panxiaofenStatus);
    }else{
        if (item.songId == nil||item.songId.length == 0) {
            return;
        }
         dispatch_async(dispatch_get_main_queue(), ^{
             [MBProgressHUD showHUDAddedTo:self.view animated:YES];
             [[self class]cancelPreviousPerformRequestsWithTarget:self selector:@selector(downloadItem:isVideo:callBack:) object:nil];
        });
        [PayApi queryTicketsWithMobile:[UserManager shareInstance].currentUser.phone productId:item.songId productType:abool?@"2":@"1" channelId:ChannelId_ portal:Portal_ callBack:^(NSDictionary *data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (data) {
                    NSString * status = data[@"code"];
                    if (![status isEqualToString:@"0000"]) {
                        NSLog(@"%@",data[@"desc"]);
                    }
                    if(OCSTR(@"%@",data[@"statu"]).intValue == 1){
                        _panxiaofenStatus = PanxiaofenStatusDownLoad;
                        call(_panxiaofenStatus);
                        return ;
                    }else{
                        _panxiaofenStatus = PanxiaofenStatusNoneTicket;
                        call(_panxiaofenStatus);
                        return ;
                    }
                }else{
                    _panxiaofenStatus = PanxiaofenStatusWait;
                    call(_panxiaofenStatus);
                    return ;
                }
                
            });
        }];
    }
}

- (void)downloadItem:(StandarItem *)item andDownloadType:(DownloadType)type
{
    [self checkNetbilityAndShowAlert];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    DownloadItem *aItem = [[DownloadItem alloc] init];
    aItem.songId = item.songId;
    aItem.name = item.songName;//[NSString stringWithFormat:@"aItem.name %d", 1];
    aItem.imageUrl = item.imageUrl;//@"http://c.hiphotos.baidu.com/baike/w%3D268/sign=b1677f3dd70735fa91f049bfa6500f9f/8b82b9014a90f60369f241613a12b31bb051ed52.jpg";
    aItem.url = item.downUrl;//@"http://res3.imuapp.cn/118.85.203.45/res/thirdparty/V/2130/mp3/50/02/16/2130500216000800.mp3";
    aItem.singer = item.singerName;//@"中英双字幕";
    aItem.singerId = item.singerId;//[NSString stringWithFormat:@"25"];
    aItem.lyricUrl = item.lyricUrl;//@"http://s.geci.me/lrc/166/16685/1668536.lrc";
    //    aItem.listenUrl = tempSong.listenUrl;//下载后不要保存试听地址，因为会用试听地址来做判断，判断是否是试听
    aItem.localPath = @"";
    aItem.localTempPath = @"";
    aItem.downloaddate = @"";
    aItem.downloadtime = @"";
    aItem.loadType = type;
    if (aItem.loadType == DownloadTypeVideo) {
        if (aItem.url.length == 0) {
            [self showAlert:@"下载地址失效" andDisAppearAfterDelay:1.5];
            return;
        }
        if ([[DownloadManager sharedInstance] isLocalWithVideoItemID:aItem.songId]) {
            [self showAlert:@"MTV已下载" andDisAppearAfterDelay:1.5];
        }else if ([[DownloadManager sharedInstance] isDownloadingVideoItemWithID:aItem.songId]) {
            [self showAlert:@"MTV已添加到下载列表" andDisAppearAfterDelay:1.5];
        }else {
            [[DownloadManager sharedInstance] fetchWithItem:aItem];
            [self showAlert:@"MTV已添加到下载列表" andDisAppearAfterDelay:1.5];
        }
    }else{
        if ([[DownloadManager sharedInstance] isLocalWithMusicItemID:aItem.songId]) {
            [self showAlert:@"歌曲已下载" andDisAppearAfterDelay:1.5];
        }else if ([[DownloadManager sharedInstance] isDownloadingMusicItemWithID:aItem.songId]) {
            [self showAlert:@"歌曲已添加到下载列表" andDisAppearAfterDelay:1.5];
        }else {
            [[DownloadManager sharedInstance] fetchWithItem:aItem];
            [self showAlert:@"歌曲已添加到下载列表" andDisAppearAfterDelay:1.5];
        }
    }
}

- (void)playerMusic:(StandarItem *)contentId
{

    [self checkNetbilityAndShowAlert];
    if (![contentId.isFree isEqualToString:@"0"]&&[contentId.isFull isEqualToString:@"0"]&&contentId.listenUrl.length == 0) {

    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    DownloadItem *aItem = [[DownloadItem alloc] init];
    aItem.songId = [NSString stringWithFormat:@"%@", contentId.songId];
    aItem.name = [NSString stringWithFormat:@"%@",contentId.songName];
    aItem.imageUrl = contentId.imageUrl;//@"http://c.hiphotos.baidu.com/baike/w%3D268/sign=b1677f3dd70735fa91f049bfa6500f9f/8b82b9014a90f60369f241613a12b31bb051ed52.jpg";
    aItem.url = contentId.downUrl;//@"http://res3.imuapp.cn/118.85.203.45/res/thirdparty/V/2130/mp3/50/02/16/2130500216000800.mp3";
    aItem.singer = contentId.singerName;//@"未知艺术家";
    aItem.singerId = [NSString stringWithFormat:@"%@", contentId.singerId];
    aItem.lyricUrl = [NSString stringWithFormat:@"%@", contentId.lyricUrl];//@"http://s.geci.me/lrc/166/16685/1668536.lrc";
    
//    aItem.lyricUrl = @"http://s.geci.me/lrc/166/16685/1668536.lrc";

    aItem.listenUrl = contentId.downUrl;//@"http://res2.imuapp.cn/resource1/a/1720/mp3/00/00/48/1720000048000800.mp3";
    aItem.localPath = @"";
    aItem.localTempPath = @"";
    aItem.downloaddate = @"";
    aItem.downloadtime = @"";
    aItem.isFree = [NSString stringWithFormat:@"%@", contentId.isFree].intValue;
    aItem.isFull = [NSString stringWithFormat:@"%@", contentId.isFull].intValue;
    aItem.loadType = DownloadTypeMusic;
    NSArray *playList = [NSArray arrayWithObject:aItem];
    [[DataCenter shareInstance].musicPlayer addPlaylist:playList];
}


- (BOOL)checkNetbilityAndShowAlert;/**<检查您的网络连接*/
{
    if (![UserManager shareInstance].netReachAbility) {
        [self showAlert:@"无网络连接，请检查您的网络连接" andDisAppearAfterDelay:1.5];
        return NO;
    }else
    return YES;
}

/**
 *   @param NS_AVAILABLE_IOS(6_0)
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(void)handleMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self back:nil];
//    if( self.view.window == nil && [self isViewLoaded]) {
//        //安全移除控制器的view;
//        self.view = nil;
//    }
}

@end
