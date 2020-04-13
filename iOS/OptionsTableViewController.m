/*
 * This file is part of MAME4iOS.
 *
 * Copyright (C) 2013 David Valdeita (Seleuco)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses>.
 *
 * Linking MAME4iOS statically or dynamically with other modules is
 * making a combined work based on MAME4iOS. Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the copyright holders of MAME4iOS
 * give you permission to combine MAME4iOS with free software programs
 * or libraries that are released under the GNU LGPL and with code included
 * in the standard release of MAME under the MAME License (or modified
 * versions of such code, with unchanged license). You may copy and
 * distribute such a system following the terms of the GNU GPL for MAME4iOS
 * and the licenses of the other code concerned, provided that you include
 * the source code of that other code when and as the GNU GPL requires
 * distribution of source code.
 *
 * Note that people who make modified versions of MAME4iOS are not
 * obligated to grant this special exception for their modified versions; it
 * is their choice whether to do so. The GNU General Public License
 * gives permission to release a modified version without this exception;
 * this exception also makes it possible to release a modified version
 * which carries forward this exception.
 *
 * MAME4iOS is dual-licensed: Alternatively, you can license MAME4iOS
 * under a MAME license, as set out in http://mamedev.org/
 */

#import "OptionsTableViewController.h"

@implementation OptionsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
#if TARGET_OS_IOS
    if (@available(iOS 13.0, *)) {
        if (style == UITableViewStyleGrouped)
            style = UITableViewStyleInsetGrouped;
    }
#endif
    return [super initWithStyle:style];
}
- (instancetype)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}
- (instancetype)initWithEmuController:(EmulatorController*)emulatorController {
    if (self = [self init]) {
        self.emuController = emulatorController;
    }
    return self;
}

- (NSString*)applicationVersionInfo {
    
    NSString* bundle_ident = NSBundle.mainBundle.bundleIdentifier;
    NSString* display_name = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];

    NSString* version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* version_num = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (![version isEqualToString:version_num])
        version = [NSString stringWithFormat:@"%@ (%@)", version, version_num];
#ifdef DEBUG
    version = [NSString stringWithFormat:@"%@ • DEBUG", version];
#endif
    
    // this is the last date Info.plist was modifed, if you do a clean build, or change the version, it is the build date.
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Info" ofType: @"plist"];
    NSDate* date = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileModificationDate];
    NSString* build_date = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    
    NSString* build_info = build_date;
    
    // look for GIT build information in Info.plist, if it is there display it.
    NSString* git_branch = [NSBundle.mainBundle objectForInfoDictionaryKey:@"git-branch"];
    NSString* git_commit = [NSBundle.mainBundle objectForInfoDictionaryKey:@"git-commit"];

    if ([git_branch isEqualToString:@"master"])
        git_branch = nil;
    
    if ([git_commit length] > 7)
        git_commit = [git_commit substringToIndex:7];
    
    if (git_branch && git_commit)
        build_info = [NSString stringWithFormat:@"%@ (%@, %@)", build_date, git_branch, git_commit];
    else if (git_commit)
        build_info = [NSString stringWithFormat:@"%@ (%@)", build_date, git_commit];

    return [NSString stringWithFormat:@"%@ • %@\n%@\n%@", display_name, version, bundle_ident, build_info];
}

#if TARGET_OS_TV
- (void)loadView {
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view = view;

    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [view addSubview:tableView];

    tableView.delegate = self;
    tableView.dataSource = self;

    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [tableView.widthAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.widthAnchor multiplier:0.5].active = TRUE;
    [tableView.topAnchor constraintEqualToAnchor:view.topAnchor].active = TRUE;
    [tableView.trailingAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.trailingAnchor].active = TRUE;
    [tableView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = TRUE;

    UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mame_logo"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:logo];
    [logo.widthAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.widthAnchor multiplier:0.4].active = TRUE;
    [logo.heightAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.heightAnchor multiplier:0.4].active = TRUE;
    [logo.topAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.topAnchor].active = TRUE;
    [logo.leadingAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.leadingAnchor].active = TRUE;
    
    UILabel* version = [[UILabel alloc] initWithFrame:CGRectZero];
    version.text = self.applicationVersionInfo;
    version.numberOfLines = 0;
    version.textColor = [UIColor lightGrayColor];
    version.textAlignment = NSTextAlignmentCenter;
    [version sizeToFit];
    version.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:version];
    
    [version.centerXAnchor constraintEqualToAnchor:logo.centerXAnchor].active = TRUE;
    [version.topAnchor constraintEqualToAnchor:logo.bottomAnchor].active = TRUE;
}

-(UITableView*)tableView {
    NSParameterAssert([self.view.subviews.firstObject isKindOfClass:[UITableView class]]);
    return self.view.subviews.firstObject;
}
#endif

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#if TARGET_OS_IOS
    // green switches are ugly, color them with our tint color.
    [[UISwitch appearance] setOnTintColor:self.view.tintColor];
    // only show the Done button on the root
    if (self.emuController != nil && self.navigationController.viewControllers.firstObject == self) {
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self.emuController action:@selector(done:)];
        self.navigationItem.rightBarButtonItem = done;
    }
#else
    // tvOS does not need a Done button, that is what the MENU button is for.
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
#endif
    [self.tableView reloadData];
}

@end
