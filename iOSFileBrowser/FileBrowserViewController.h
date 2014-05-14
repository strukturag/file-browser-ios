//
//  FileBrowserViewController.h
//  iOSFileBrowser
//
//  Created by Yuriy Shevchuk on 12/23/13.
//  Copyright (c) 2013 struktur AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FileBrowserViewController;

@protocol FileBrowserViewControllerDelegate <NSObject>
@required
- (void)fileBrowser:(FileBrowserViewController *)fileBrowser didPickFileAtPath:(NSString *)path;

@optional
- (BOOL)fileBrowser:(FileBrowserViewController *)fileBrowser shouldPresentDocumentsControllerForFileAtPath:(NSString *)path;
- (BOOL)fileBrowser:(FileBrowserViewController *)fileBrowser shouldShowEmptyDirectoryMessageAtDirectoryPath:(NSString *)directoryPath;

@end


@interface FileBrowserViewController : UIViewController

@property (nonatomic, weak) id<FileBrowserViewControllerDelegate> delegate;

@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) UIColor *tableViewBackgroundColor;

@property (nonatomic, readonly, strong) UILabel *emptyDirectoryMessageLabel;
@property (nonatomic, readonly, strong) UIView *emptyDirectoryAdditionalConatinerView;

- (id)initWithDirectoryPath:(NSString *)directoryPath;


@end
