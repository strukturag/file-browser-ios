//
//  FileBrowserViewController.m
//  iOSFileBrowser
//
//  Created by Yuriy Shevchuk on 12/23/13.
//  Copyright (c) 2013 struktur AG. All rights reserved.
//

#import "FileBrowserViewController.h"


@interface FileBrowserViewController () <UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate>
{
	NSString *_directoryPath;
	NSMutableArray *_directoryContentsArray;
    
	UIDocumentInteractionController *_documentInteractionController;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *emptyMessageContainerView;

@property (nonatomic, strong) IBOutlet UILabel *emptyDirectoryMessageLabel;
@property (nonatomic, strong) IBOutlet UIView *emptyDirectoryAdditionalConatinerView;


@property (nonatomic, strong) UIView *emptyMessageView;

@end

@implementation FileBrowserViewController

- (id)initWithDirectoryPath:(NSString *)directoryPath
{
    self = [super initWithNibName:@"FileBrowserViewController" bundle:nil];
    if (self) {
        _directoryPath = directoryPath;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Files" image:[UIImage imageNamed:@"files_black"] tag:0];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"files_white"];
		self.navigationItem.title = [_directoryPath lastPathComponent];
		
		[self populateDirectoryContentsArrayFromDirectoryAtPath:_directoryPath];
		
		self.cellBackgroundColor = [UIColor whiteColor];
		self.tableViewBackgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
	self.tableView.backgroundColor = self.tableViewBackgroundColor;
	
	if (self.emptyDirectoryMessageAttributedText) {
		self.emptyDirectoryMessageLabel.attributedText = self.emptyDirectoryMessageAttributedText;
	} else {
		self.emptyDirectoryMessageLabel.text = self.emptyDirectoryMessageText;
	}
	
	[self.tableView reloadData];
	
	if ([self.delegate respondsToSelector:@selector(fileBrowser:viewForEmptyDirectoryMessageWithSize:)] && !self.emptyMessageView) {
		self.emptyMessageView = [self.delegate fileBrowser:self viewForEmptyDirectoryMessageWithSize:self.emptyDirectoryAdditionalConatinerView.bounds.size];
		[self.emptyDirectoryAdditionalConatinerView addSubview:self.emptyMessageView];
	}
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	BOOL shouldShowEmptyDirectoryMessage = YES;
	
	if ([self.delegate respondsToSelector:@selector(fileBrowser:shouldShowEmptyDirectoryMessageAtDirectoryPath:)]) {
		shouldShowEmptyDirectoryMessage = [self.delegate fileBrowser:self shouldShowEmptyDirectoryMessageAtDirectoryPath:_directoryPath];
	}
	
	//TODO: yuriy - Add additional logic for handling '..' paths which should change _directoryPath to its supernode
	
	shouldShowEmptyDirectoryMessage = shouldShowEmptyDirectoryMessage && ([_directoryContentsArray count] <= 0);
	
	if (shouldShowEmptyDirectoryMessage) {
		self.tableView.hidden = YES;
		self.emptyMessageContainerView.hidden = NO;
	} else {
		self.tableView.hidden = NO;
		self.emptyMessageContainerView.hidden = YES;
	}
}


#pragma mark - Actions

- (void)dismiss
{
	if (self.presentingViewController) {
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}


#pragma mark - Public

- (void)reloadViewForEmptyMessage
{
	[self.emptyMessageView removeFromSuperview];
	self.emptyMessageView = nil;
	
	if ([self.delegate respondsToSelector:@selector(fileBrowser:viewForEmptyDirectoryMessageWithSize:)]) {
		self.emptyMessageView = [self.delegate fileBrowser:self viewForEmptyDirectoryMessageWithSize:self.emptyDirectoryAdditionalConatinerView.bounds.size];
		[self.emptyDirectoryAdditionalConatinerView addSubview:self.emptyMessageView];
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
	if (!_documentInteractionController) {
		_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
	}
	_documentInteractionController.URL = url;
	
	cell.imageView.image = [_documentInteractionController.icons objectAtIndex:0];
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
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
																message:@"We are sorry but you do not have any application that can open this file"
															   delegate:nil
													  cancelButtonTitle:@"OK"
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
