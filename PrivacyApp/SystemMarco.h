//
//  SystemMarco.h
//  PrivacyApp
//
//  Created by Apple on 2019/11/27.
//  Copyright © 2019 Geniune. All rights reserved.
//

#ifndef SystemMarco_h
#define SystemMarco_h


//输出日志宏
#define DebugLog(format, ...) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(format),  ##__VA_ARGS__] )

#endif /* SystemMarco_h */
