//
//  EGORefreshTableHeaderView.m
//  Demo
//
//修改人：李浩 iphone开发qq：419590779 邮箱：ss_lihao@163.com
//


#define  RefreshViewHight 65.0f

#import "EGORefreshTableFootView.h"
#import "NSAttributedString+Additions.h"



@interface EGORefreshTableFootView (Private)
- (void)setState:(EGOPullRefreshState1)aState;
@end

@implementation EGORefreshTableFootView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, RefreshViewHight - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = DEFAULT_TAG_FONT;
		label.textColor = DEFAULT_TAG_COLOR;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
               [self addSubview:label];
		_statusLabel=label;
		[label release];
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(105.0f, RefreshViewHight - 46.0f, 15.0f, 15.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
		
		
		[self setState:EGOOPullRefreshNormal1];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableFootDataSourceLastUpdated:)]) {
		
		//NSDate *date = [_delegate egoRefreshTableFootDataSourceLastUpdated:self];
		
//		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//		[formatter setAMSymbol:@"上午"];
//		[formatter setPMSymbol:@"下午"];
//		[formatter setDateFormat:@"yyyy/MM/dd hh:mm:a"];
//		_lastUpdatedLabel.text = [NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:date]];
//        
//		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//		[formatter release];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}

}

- (void)setState:(EGOPullRefreshState1)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling1:
        {
            UIColor *shadowColor=[UIColor colorWithWhite:0.9f alpha:1.0f];
            _statusLabel.attributedText =[NSMutableAttributedString setLabelTextShadowWitText:NSLocalizedString(@"", @"") WithColor:shadowColor withOffset:CGSizeMake(0, 1)];
			break;
        }
		case EGOOPullRefreshNormal1:
        {
            UIColor *shadowColor=[UIColor colorWithWhite:0.9f alpha:1.0f];
            _statusLabel.attributedText =[NSMutableAttributedString setLabelTextShadowWitText:NSLocalizedString(@"", @"") WithColor:shadowColor withOffset:CGSizeMake(0, 1)];

			[_activityView stopAnimating];
			[self refreshLastUpdatedDate];
			
			break;
        }
		case EGOOPullRefreshLoading1:
        {
            UIColor *shadowColor=[UIColor colorWithWhite:0.9f alpha:1.0f];
            _statusLabel.attributedText =[NSMutableAttributedString setLabelTextShadowWitText:NSLocalizedString(@"加载中⋯", @"加载中⋯") WithColor:shadowColor withOffset:CGSizeMake(0, 1)];
            
			[_activityView startAnimating];
			
			break;
        }
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

//手指屏幕上不断拖动调用此方法
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_state == EGOOPullRefreshLoading1) {
		
//		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
//		offset = MIN(offset, 60);
        scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, (_hasContentInset ? RefreshViewHight+TAB_BAR_HEIGHT : RefreshViewHight), 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableFootDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableFootDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling1 && scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + RefreshViewHight && scrollView.contentOffset.y > 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal1];
		} else if (_state == EGOOPullRefreshNormal1 && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight  && !_loading) {
			[self setState:EGOOPullRefreshPulling1];
		}
		
		if (scrollView.contentInset.bottom != 0) {
			scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, (_hasContentInset ? TAB_BAR_HEIGHT : 0), 0.0f);
		}
		
	}
	
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableFootDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableFootDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableFootDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableFootDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading1];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, (_hasContentInset ? RefreshViewHight+TAB_BAR_HEIGHT : RefreshViewHight), 0.0f);
		[UIView commitAnimations];
		
	}
	
}

//当开发者页面页面刷新完毕调用此方法，[delegate egoRefreshScrollViewDataSourceDidFinishedLoading: scrollView];
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, (_hasContentInset ? TAB_BAR_HEIGHT : 0), 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal1];

}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	//_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}


@end
