//
//  Defines.h
//  KuaiPanTool
//
//  Created by Jinbo He on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

typedef enum {
    kCompileTypeTest = 1,
    kCompileTypeAppStore,
    kCompileType91,
    kCompileTypeTongbutui,
    kCompileTypeOther,

} CompileType;

#define CONFIG_FILENAME     @"Config.cfg"
#define VERSION_FILENAME    @"version.bak"
#define SHELL_FILENAME      @"Kuaipan"

#define KCODE_PATH          @"kCodePath"
#define KINFO_NAME          @"kInfoName"
#define KINIT_VERSION       @"kInitVersion"
#define KTEST_VERSION       @"kTestVersion"
#define KOUTPUT_PATH        @"kOutputPath"
#define KOUTPUT_FILENAME    @"kOutputFile"

#define KBUILD_91           @"kBuild91"
#define KBUILD_TONGBUTUI    @"kBuildTongbutui"
#define KBUILD_OTHER        @"kBuildOther"

#define INIT_PATH       @"/Users/hejinbo/Work/KuaiPan_iPad/KuaiPan/trunk/LiveSpace"