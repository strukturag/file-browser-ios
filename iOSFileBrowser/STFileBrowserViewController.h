/**
 * @copyright Copyright (c) 2014-2017 Struktur AG
 * @author Yuriy Shevchuk
 * @author Ivan Sein <ivan@nextcloud.com>
 *
 * @license GNU GPL version 3 or any later version
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

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

@property (nonatomic, copy) NSString *noAppToOpenFileAlertTitle;
@property (nonatomic, copy) NSString *noAppToOpenFileAlertMessage;
@property (nonatomic, copy) NSString *noAppToOpenFileAlertOkButtonLabel;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *emptyDirectoryContainerView;
@property (nonatomic, strong) IBOutlet UILabel *emptyDirectoryMessageLabel;

- (id)initWithDirectoryPath:(NSString *)directoryPath;

- (void)setEmptyDirectoryView:(UIView *)view;
- (void)dismiss;
- (void)populateDirectoryContentsArrayFromDirectoryAtPath:(NSString *)directoryPath;
- (BOOL)checkIfDirectory:(NSString *)directory1 isEqualToDirectory:(NSString *)directory2;

@end
