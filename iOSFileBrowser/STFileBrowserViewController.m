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

#import "STFileBrowserViewController.h"


@interface STFileBrowserViewController () <UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate>
{
	NSString *_directoryPath;
	NSMutableArray *_directoryContentsArray;
    
	UIDocumentInteractionController *_documentInteractionController;
    UIDocumentInteractionController *_iconsDocumentInteractionController;
    
    NSTimer *_refreshDirectoryContentTimer;
}

@property (nonatomic, strong) UIView *userEmptyDirectoryView;

@end

@implementation STFileBrowserViewController

- (id)initWithDirectoryPath:(NSString *)directoryPath
{
    self = [super initWithNibName:@"STFileBrowserViewController" bundle:nil];
    if (self) {
        _directoryPath = directoryPath;
		self.navigationItem.title = [_directoryPath lastPathComponent];
        		
		self.cellBackgroundColor = [UIColor whiteColor];
		self.tableViewBackgroundColor = [UIColor whiteColor];
		
		
		self.emptyDirectoryMessageText = NSLocalizedStringWithDefaultValue(@"There is no files in this directory.",
																		   nil, [NSBundle mainBundle],
																		   @"There is no files in this directory.",
																		   @"");
		
		self.noAppToOpenFileAlertTitle = nil;
		self.noAppToOpenFileAlertMessage = NSLocalizedStringWithDefaultValue(@"We are sorry but you do not have any application that can open this file",
																			 nil, [NSBundle mainBundle],
																			 @"We are sorry but you do not have any application that can open this file",
																			 @"");
		self.noAppToOpenFileAlertOkButtonLabel = NSLocalizedStringWithDefaultValue(@"OK",
																				   nil, [NSBundle mainBundle],
																				   @"OK",
																				   @"");
    }
    return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [_refreshDirectoryContentTimer invalidate];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.tableView.backgroundColor = self.tableViewBackgroundColor;
	
	if (self.emptyDirectoryMessageAttributedText) {
		self.emptyDirectoryMessageLabel.attributedText = self.emptyDirectoryMessageAttributedText;
	} else {
		self.emptyDirectoryMessageLabel.text = self.emptyDirectoryMessageText;
	}
	
	[self.tableView reloadData];
	
	if ([self.delegate respondsToSelector:@selector(fileBrowserHasLoadedItsView:)]) {
		[self.delegate fileBrowserHasLoadedItsView:self];
	}
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if (self.hasDismissButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    }
	
	//TODO: yuriy - Add additional logic for handling '..' paths which should change _directoryPath to its supernode
    
    [self refreshFileBrowserViewWithDirectoryAtPath:_directoryPath];
    
     _refreshDirectoryContentTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerTicked:) userInfo:nil repeats:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_refreshDirectoryContentTimer invalidate];
}


#pragma mark - Actions

- (void)dismiss
{
	if (self.presentingViewController) {
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}


#pragma mark - Timers

- (void)timerTicked:(NSTimer*)timer
{
    [self refreshFileBrowserViewWithDirectoryAtPath:_directoryPath];
}


#pragma mark - Public

- (void)setEmptyDirectoryView:(UIView *)view
{
	if (view) {
		self.emptyDirectoryMessageLabel.hidden = YES;
		self.userEmptyDirectoryView = view;
		[self.emptyDirectoryContainerView addSubview:self.userEmptyDirectoryView];
	} else {
		self.emptyDirectoryMessageLabel.hidden = NO;
		[self.userEmptyDirectoryView removeFromSuperview];
		self.userEmptyDirectoryView = nil;
	}
}


#pragma mark - UIViewController Rotation

- (NSUInteger)supportedInterfaceOrientations
{
	NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
	}
	
	return supportedInterfaceOrientations;
}


#pragma mark -

- (void)populateDirectoryContentsArrayFromDirectoryAtPath:(NSString *)directoryPath
{
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
	_directoryContentsArray = [[NSMutableArray alloc] initWithArray:contents];
	[_directoryContentsArray sortUsingSelector:@selector(compare:)];
}


- (BOOL)checkIfDirectory:(NSString *)directory1 isEqualToDirectory:(NSString *)directory2
{
	BOOL answer = NO;
	
	if ([directory1 length] > 0 && [directory2 length] > 0) {
		directory1 = [directory1 stringByDeletingPathExtension];
		directory2 = [directory2 stringByDeletingPathExtension];
		
		answer = [directory1 isEqualToString:directory2];
	}
	
	return answer;
}


- (void)refreshFileBrowserViewWithDirectoryAtPath:(NSString *)directoryPath
{
    BOOL shouldShowEmptyDirectoryMessage = YES;
    
    [self populateDirectoryContentsArrayFromDirectoryAtPath:directoryPath];
    
    if ([self.delegate respondsToSelector:@selector(fileBrowser:shouldShowEmptyDirectoryMessageAtDirectoryPath:)]) {
        shouldShowEmptyDirectoryMessage = [self.delegate fileBrowser:self shouldShowEmptyDirectoryMessageAtDirectoryPath:_directoryPath];
    }
    
    if (shouldShowEmptyDirectoryMessage && ([_directoryContentsArray count] <= 0)) {
        self.tableView.hidden = YES;
        self.emptyDirectoryContainerView.hidden = NO;
    } else {
        self.tableView.hidden = NO;
        self.emptyDirectoryContainerView.hidden = YES;
    }
    
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_directoryContentsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"FileBrowserTableViewCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}
    
    NSString *path = [_directoryContentsArray objectAtIndex:indexPath.row];
    NSURL *url = [NSURL fileURLWithPathComponents:@[_directoryPath, path]];
    if (!_iconsDocumentInteractionController) {
        _iconsDocumentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    }
    _iconsDocumentInteractionController.URL = url;
	
	cell.imageView.image = [_iconsDocumentInteractionController.icons objectAtIndex:0];
	cell.textLabel.text = [_directoryContentsArray objectAtIndex:indexPath.row];
	cell.detailTextLabel.text = nil;
	
	cell.backgroundColor = self.cellBackgroundColor;	
	
	return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}


#pragma mark - UITableViewDelegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *path = [_directoryContentsArray objectAtIndex:indexPath.row];
	NSURL *url = [NSURL fileURLWithPathComponents:@[_directoryPath, path]];
//
//	NSString *fullPath = [url absoluteString];
//	fullPath = [fullPath substringFromIndex:7]; // 'file://'
	
	NSString *fullPath = [_directoryPath stringByAppendingPathComponent:path];
	
	BOOL shouldPresentDocumentsController = YES;
	
	if ([self.delegate respondsToSelector:@selector(fileBrowser:shouldPresentDocumentsControllerForFileAtPath:)]) {
		shouldPresentDocumentsController = [self.delegate fileBrowser:self shouldPresentDocumentsControllerForFileAtPath:fullPath];
	}
	
	[self.delegate fileBrowser:self didPickFileAtPath:fullPath];
	
	if (shouldPresentDocumentsController) {
	
		if (!_documentInteractionController) {
			_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
		}
		_documentInteractionController.URL = url;
		_documentInteractionController.delegate = self;
		
		BOOL canPreview = [_documentInteractionController presentPreviewAnimated:YES];
		
		if (!canPreview) {
			BOOL canShowActions = [_documentInteractionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
			if (!canShowActions) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.noAppToOpenFileAlertTitle
																message:self.noAppToOpenFileAlertMessage
															   delegate:nil
													  cancelButtonTitle:self.noAppToOpenFileAlertOkButtonLabel
													  otherButtonTitles:nil];
				
				[alert show];
			}
		}
	}
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *path = [_directoryContentsArray objectAtIndex:indexPath.row];
		NSURL *url = [NSURL fileURLWithPathComponents:@[_directoryPath, path]];
		[_directoryContentsArray removeObject:path];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			[[NSFileManager defaultManager] removeItemAtURL:url error:nil];
		});
    }
}


#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}


@end
