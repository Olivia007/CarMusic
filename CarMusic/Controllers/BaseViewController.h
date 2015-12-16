//
//  BaseViewController.h
//  CarClub
//
//  Created by DarrenKong on 15/7/7.
//  Copyright © 2015年 wacosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAVPlayer.h"
#import "DataCenter.h"
#import "Audio.h"
#import "AppDelegate.h"
#import "BaseView.h"
#import "FengchaoDataBase.h"
#import "StandarItem.h"
typedef enum DataLoadStatus
{
    DLStatusReady,
    DLStatusLoading,
    DLStatusFinished,
    DLStatusFaild
}DLStatus;


typedef enum VCStatus
{
    VCStatusInit,
    VCStatusDidLoad,
    VCStatusAppear,
    VCStatusDisAppear,
}VCStatus;

typedef enum PanxiaofenStatus
{
    PanxiaofenStatusWait   = 0 ,           /**<等待*/
    PanxiaofenStatusNoLogin,               /**<没登陆*/
    PanxiaofenStatusDownLoad,              /**<有券*/
    PanxiaofenStatusNoneTicket,            /**<没券，需要购买*/
}PanxiaofenStatus;

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UINavigationBar  *naviBar;
@property (nonatomic, strong) UIColor          *themeColor;//本页面的主题颜色
@property (nonatomic, assign) BOOL             enableContentScroll;
@property (nonatomic, assign) BOOL             freshWhenAppear;
@property (nonatomic, assign) DLStatus         status;

@property (nonatomic, strong) BaseView         *baseView;

@property (nonatomic, assign) BOOL             isShowPlayer;

@property (nonatomic, strong) MyAVPlayer       *miniPlayer;

@property (nonatomic, assign) CGFloat          bottomOffset;

- (void)showAlert:(NSString *)str andDisAppearAfterDelay:(float)time;

- (void)creatWidgets;/**<UI创建*/

- (void)refreshItemStatus:(NSNotification *)notification;

- (void)loadData;

- (void)layoutSubViews;

- (BOOL)isLogin;

- (void)showLoginVC;

- (void)viewDidCurrentView;

- (void)judgeItem:(StandarItem *)contentId isVideo:(BOOL)abool;
/**
 *   网络请求是否可以下载：回调 ：PanxiaofenStatus
 */
- (void)downloadItem:(StandarItem *)item isVideo:(BOOL)abool callBack:(void(^)(PanxiaofenStatus status))call;
/**
 *  下载方法  参数：StandarItem
 */
- (void)downloadItem:(StandarItem *)item andDownloadType:(DownloadType)type;

- (void)playerMusic:(StandarItem *)contentId;

- (BOOL)checkNetbilityAndShowAlert;

- (void)setNavBarBarItem:(NSString *)aImageName target:(id)aTarget action:(SEL)aAction atRight:(BOOL)aRight;

- (void)setNavBarBarItemWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)aAction atRight:(BOOL)aRight;

- (void)pushViewController:(BaseViewController *)controller;

- (void)homeBack:(id)sender;

- (void)back:(id)sender;

@end
