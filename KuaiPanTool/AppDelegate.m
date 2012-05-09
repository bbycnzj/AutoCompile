//
//  AppDelegate.m
//  KuaiPanTool
//
//  Created by Jinbo He on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Defines.h"

@implementation AppDelegate

@synthesize window = _window;


#pragma mark - Init & dealloc methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *dictCfg = nil;
    
    if ([fm fileExistsAtPath:[self getConfigPath]]) {
        dictCfg = [NSDictionary dictionaryWithContentsOfFile:[self getConfigPath]];
        
        _txtInitVersion.stringValue = [dictCfg objectForKey:KINIT_VERSION];
        _txtInfoPlist.stringValue = [dictCfg objectForKey:KINFO_NAME];
        _txtOutputPath.stringValue = [dictCfg objectForKey:KOUTPUT_PATH];
        _txtOutputFile.stringValue = [dictCfg objectForKey:KOUTPUT_FILENAME];
        
        NSString *pathOld=[dictCfg objectForKey:KCODE_PATH];
        NSArray *codePaths = [dictCfg objectForKey:KCODE_PATHS];
        if (codePaths==nil && pathOld != nil) {
            codePaths = [NSArray arrayWithObjects:pathOld, nil];
        }
        for (NSString *path in codePaths) {
            [_comboxCodePath addItemWithObjectValue:path];
        }
        if (codePaths.count >0) {
            _comboxCodePath.stringValue = [codePaths objectAtIndex:0];
        }
    }
    else {
        _comboxCodePath.stringValue = INIT_PATH;
        [_comboxCodePath addItemWithObjectValue:INIT_PATH];
        _txtInfoPlist.stringValue = @"LiveSpace-Info.plist";
        _txtOutputPath.stringValue = NSHomeDirectory();
        _txtOutputFile.stringValue = @"KuaipanHD";
        [self setInitVer];
        
        [self doSaveConfig:nil];//保存
    }
    
    _txtTestVersion.stringValue = [self getVersionTest];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    }	
    else
    {
        [_window makeKeyAndOrderFront:self];
        return YES;	
    }
}

- (void)dealloc
{
    [super dealloc];
}


#pragma mark - NSTextFiledDelegate methods

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    [self setInitVer];
    _txtTestVersion.stringValue = [self getVersionTest];

    [self doSaveConfig:nil];
}


#pragma mark - Handle event methods

- (NSString *)getConfigPath
{  
    // 配置文件路径
    NSString *configPath = [NSString stringWithFormat:@"%@/%@",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent], CONFIG_FILENAME];
    return configPath;
}

- (NSString *)getLogPath
{
    NSString *logPath = [NSString stringWithFormat:@"%@/%@.log",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent], _txtOutputFile.stringValue];
    return logPath;
}

- (NSString *)getShellPath
{
    NSString *shellPath = [NSString stringWithFormat:@"%@/%@",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent], SHELL_FILENAME];
    return shellPath;
}

- (NSString *)getInfoPath
{
    NSString *infoPath = [_comboxCodePath.stringValue stringByAppendingPathComponent:_txtInfoPlist.stringValue];
    
    return infoPath;
}

- (NSString *)getVersionPath
{
    NSString *versionPath = [NSString stringWithFormat:@"%@/%@",[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent], VERSION_FILENAME];
    
    return versionPath;
}

- (NSString *)getVersionTest
{
    NSMutableDictionary *dict = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getVersionPath]]) {
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self getVersionPath]];
    }
    
    NSString *version = _txtInitVersion.stringValue;
    NSString *versionTest = [dict objectForKey:KTEST_VERSION];
    
    if ([version floatValue] > [versionTest floatValue]) {
        versionTest = [NSString stringWithFormat:@"%@.1",version];
    }
    else {
        NSArray *vers=[versionTest componentsSeparatedByString:@"."];
        NSMutableArray *verArray = [NSMutableArray arrayWithArray:vers];
        NSString *lastVer = [verArray lastObject];

        [verArray removeLastObject];
        [verArray addObject:[NSString stringWithFormat:@"%d",[lastVer intValue]+1]];
        versionTest = [verArray componentsJoinedByString:@"."];
    }
    
    return versionTest;
}

- (void)setVersionTest:(NSString *)version
{
    if ([version floatValue] < [_txtInitVersion.stringValue floatValue]) {
        version = [NSString stringWithFormat:@"%@.1",_txtInitVersion.stringValue]; 
    }
    
    NSMutableDictionary *dict = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getVersionPath]]) {
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[self getVersionPath]];
    }
    else {
        dict = [[NSMutableDictionary alloc] init];
    }
    
    [dict setObject:version forKey:KTEST_VERSION];
    [dict writeToFile:[self getVersionPath] atomically:YES];

    [dict release];
}

- (void)setInitVer
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self getInfoPath]];
    
    if (dict != nil) {
        _txtInitVersion.stringValue = [dict objectForKey:(NSString *)kCFBundleVersionKey];
        [self doClearLog:nil];
    }
    else {
        NSTextView *log = [_txtLog documentView];
        log.string = @"请查看代码路径及Info.plist值是否正确，没有找到Info.plist文件";
    }
}

- (void)setInfoPlistVer:(NSString *)version
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self getInfoPath]];
    
    [dict setObject:version forKey:(NSString *)kCFBundleVersionKey];
    [dict setObject:version forKey:@"CFBundleShortVersionString"];
    [dict writeToFile:[self getInfoPath] atomically:YES];
}

- (void)showLogInfo
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:[self getLogPath]]) {
        NSString *content = [NSString stringWithContentsOfFile:[self getLogPath] encoding:NSUTF8StringEncoding error:nil];
        
        NSTextView *log = _txtLog.documentView;
        log.string = [NSString stringWithFormat:@"%@\r\n%@",log.string, content];
        
        [fm removeItemAtPath:[self getLogPath] error:nil];
    }
    
    [_txtLog.documentView scrollToEndOfDocument:self];
}

- (IBAction)doSaveConfig:(id)sender
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSArray *codePaths = [_comboxCodePath objectValues];
    if (codePaths.count != 0) {
        [dict setObject:codePaths forKey:KCODE_PATHS];
    }
    
    if (_txtInitVersion.stringValue != nil && _txtInfoPlist.stringValue != nil) {
        
        [dict setObject:_txtInitVersion.stringValue forKey:KINIT_VERSION];
        [dict setObject:_txtInfoPlist.stringValue forKey:KINFO_NAME];        
    }
    if (_txtOutputFile.stringValue != nil && _txtOutputPath.stringValue !=nil) {
        [dict setObject:_txtOutputFile.stringValue forKey:KOUTPUT_FILENAME];
        [dict setObject:_txtOutputPath.stringValue forKey:KOUTPUT_PATH];   
    }
    
    [dict setObject:@"#define BUILD_91_VERSION" forKey:KBUILD_91];
    [dict setObject:@"#define BUILD_TONGBUTUI" forKey:KBUILD_TONGBUTUI];
    [dict setObject:@"#define BUILD_OTHER" forKey:KBUILD_OTHER];
    
    [dict writeToFile:[self getConfigPath] atomically:YES];
}

- (void)internaleCompileTest
{
    [self internalCompile:kCompileTypeTest];
    [_indicator stopAnimation:self];
}

- (IBAction)doCompileTest:(id)sender
{
    [self doClearLog:nil];
    
    [_indicator startAnimation:self];
    [self performSelector:@selector(internaleCompileTest) withObject:nil afterDelay:0];
}

- (void)internaleDistribution
{
    NSView *contentV = [_window contentView];
    NSButton *check = [contentV viewWithTag:kCompileTypeAppStore];
    
    if (check.state == YES) {
        [self internalCompile:kCompileTypeAppStore];
    }
    
    check = [contentV viewWithTag:kCompileType91];
    if (check.state == YES) {
        [self internalCompile:kCompileType91];
    }
    
    check = [contentV viewWithTag:kCompileTypeTongbutui];
    if (check.state == YES) {
        [self internalCompile:kCompileTypeTongbutui];
    }
    
    check = [contentV viewWithTag:kCompileTypeOther];
    if (check.state == YES) {
        [self internalCompile:kCompileTypeOther];
    }
    
    [_indicator stopAnimation:self];
}

- (IBAction)doCompileDistribution:(id)sender
{
    [self doClearLog:nil];
    
    [_indicator startAnimation:self];
    [self performSelector:@selector(internaleDistribution) withObject:nil afterDelay:0];    
}

- (IBAction)doClearLog:(id)sender
{
    NSTextView *log = _txtLog.documentView;
    log.string = @"";
}

- (void)addPathItem:(NSString *)path
{
    // 检查是否已存在
    NSArray *paths = [_comboxCodePath objectValues];
    
    for (NSString *file in paths) {
        if (![file isEqualToString:path]) {
            
            [_comboxCodePath addItemWithObjectValue:path];
            [self doSaveConfig:nil];
            break;
        }
    }
}

- (IBAction)doSelectPath:(id)sender
{
    NSOpenPanel *pan = [[NSOpenPanel alloc] init];
    
    [pan setTitle:@"选择代码路径"];
    [pan setCanChooseDirectories:YES];
    [pan setDirectoryURL:[NSURL fileURLWithPath:_comboxCodePath.stringValue]];
    [pan beginSheetModalForWindow:_window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            _comboxCodePath.stringValue = [[pan URL] path];
            [self addPathItem:_comboxCodePath.stringValue];
        }
    }];
    
    [pan release];
}

- (IBAction)doOpenPath:(id)sender
{
    NSString *cmd = [NSString stringWithFormat:@"open %@", _txtOutputPath.stringValue];
    system([cmd UTF8String]);
}

- (void)internalCompile:(CompileType)type
{
    NSString *arg1 = _comboxCodePath.stringValue;
    NSString *arg2 = @"Distribution";
    NSString *arg3 = _txtInitVersion.stringValue;
    NSString *arg4 = @"Appstore";
    NSString *arg5 = _txtOutputFile.stringValue;
    NSString *arg6 = _txtOutputPath.stringValue;
    NSString *arg7 = @"";
    NSDictionary *dictConfig = [NSDictionary dictionaryWithContentsOfFile:[self getConfigPath]];
    
    if (type == kCompileTypeTest) {
        arg2 = @"Release";
        arg3 = _txtTestVersion.stringValue;
       [self setInfoPlistVer:arg3];
        
        arg4 = @"Test";
    }
    else if (type == kCompileType91){
        arg4 = @"91";
        arg7 = [dictConfig objectForKey:KBUILD_91];
    }
    else if (type == kCompileTypeTongbutui){
        arg4 = @"Tongbutui";
        arg7 = [dictConfig objectForKey:KBUILD_TONGBUTUI];
    }
    else if (type == kCompileTypeOther){
        arg4 = @"Other";
        arg7 = [dictConfig objectForKey:KBUILD_OTHER];
    }

    NSString *systemCmd = [NSString stringWithFormat:@"sh %@ %@ %@ %@ %@ %@ %@ %@",
                        [self getShellPath],
                        arg1,arg2,arg3,arg4,arg5,arg6,arg7
                        ];
    
    system([systemCmd UTF8String]);
    
    if (type == kCompileTypeTest) {
        [self setInfoPlistVer:_txtInitVersion.stringValue];
        
        [self setVersionTest:_txtTestVersion.stringValue];
        _txtTestVersion.stringValue = [self getVersionTest];
    }
    
    [self showLogInfo];
}

@end
