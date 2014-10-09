//
//  STFileBrowserViewController.h
//  iOSFileBrowser
//
//  Created by Yuriy Shevchuk on 12/23/13.
//  Copyright (c) 2013 struktur AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@class STFileBrowserViewController;

@protocol FileBrowserViewControllerDelegate <NSObject>
@required
- (void)fileBrowser:(STFileBrowserViewController *)fileBrowser didPickFileAtPath:(NSString *)path;

@optional
- (BOOL)fileBrowser:(STFileBrowserViewController *)fileBrowser shouldPresentDocumentsControllerForFileAtPath:(NSString *)path;
- (BOOL)fileBrowser:(STFileBrowserViewController *)fileBrowser shouldShowEmptyDirectoryMessageAtDirectoryPath:(NSString *)directoryPath;

- (void)fileBrowserHasLoadedItsView:(STFileBrowserViewController *)fileBrowser;

@end


@interface STFileBrowserViewController : UIViewController

@property (nonatomic, weak) id<FileBrowserViewControllerDelegate> delegate;

@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) UIColor *tableViewBackgroundColor;

@property (nonatomic, assign) BOOL hasDismissButton;

@property (nonatomic, strong) NSString *emptyDirectoryMessageText;
@property (nonatomic, strong) NSAttributedString *emptyDirectoryMessageAttributedText;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *emptyDirectoryContainerView;
@property (nonatomic, strong) IBOutlet UILabel *emptyDirectoryMessageLabel;

- (id)initWithDirectoryPath:(NSString *)directoryPath;

- (void)setEmptyDirectoryView:(UIView *)view;
- (void)dismiss;
- (void)populateDirectoryContentsArrayFromDirectoryAtPath:(NSString *)directoryPath;
- (BOOL)checkIfDirectory:(NSString *)directory1 isEqualToDirectory:(NSString *)directory2;

@end
