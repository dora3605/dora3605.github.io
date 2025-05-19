#import <UIKit/UIKit.h>
#include "Includes.h"
#import "Lib/mahoa.h"
#import "Security/oxorany.h"
#import "Security/oxorany_include.h"
#import "imgui/imgui.h" 

#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^
#import "LoadView.h"

@interface MenuLoad()
@property (nonatomic, strong) ImGuiDrawView *vna;
@property (nonatomic, strong) CAShapeLayer *glowLayer; // Viền chính
@property (nonatomic, strong) CAShapeLayer *glowLayerOuter; // Viền ngoài thứ nhất
@property (nonatomic, strong) CAShapeLayer *glowLayerOuterMost; // Viền ngoài thứ hai (mới)

@property (nonatomic, strong) UIView *introView; // View cho intro 3D
@property (nonatomic, strong) UIView *flashView; // View cho hiệu ứng sáng toàn màn hình

// Hình tâm ngắm
@property (nonatomic, strong) UIButton *circleButton; // Nút hình tròn
@property (nonatomic, strong) UIView *overlayView;    // Lớp phủ màu đỏ khi chạm

- (ImGuiDrawView*) GetImGuiView;
@end

static MenuLoad *extraInfo;

UIButton* InvisibleMenuButton;
UIButton* VisibleMenuButton;
MenuInteraction* menuTouchView;
UITextField* hideRecordTextfield;
UIView* hideRecordView;
ImVec2 menuPos, menuSize;
UIView* menuBackground; // Nền chữ nhật cho icon menu
UILabel* fpsLabel; // Label hiển thị FPS

@interface MenuInteraction()
@end

@implementation MenuInteraction

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}

@end

@implementation MenuLoad

- (ImGuiDrawView*) GetImGuiView
{
    return _vna;
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info)
{   
    timer(3) {
        extraInfo = [MenuLoad new]; // Khởi tạo menu
        [extraInfo setupMenuComponents]; // Gọi

    });
}

__attribute__((constructor)) static void initialize()
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
}


- (void)startGlowAnimation 
{
    self.glowLayer.hidden = NO;
    self.glowLayerOuter.hidden = NO;
    self.glowLayerOuterMost.hidden = NO;
    CABasicAnimation *glowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    glowAnimation.fromValue = @(0.5);
    glowAnimation.toValue = @(0.2);
    glowAnimation.duration = 0.3;
    glowAnimation.autoreverses = YES;
    glowAnimation.repeatCount = HUGE_VALF;
    [self.glowLayer addAnimation:glowAnimation forKey:@"glowAnimation"];
    CABasicAnimation *glowOuterAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    glowOuterAnimation.fromValue = @(0.3);
    glowOuterAnimation.toValue = @(0.1);
    glowOuterAnimation.duration = 0.3;
    glowOuterAnimation.autoreverses = YES;
    glowOuterAnimation.repeatCount = HUGE_VALF;
    [self.glowLayerOuter addAnimation:glowOuterAnimation forKey:@"glowOuterAnimation"];
    CABasicAnimation *glowOuterMostAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    glowOuterMostAnimation.fromValue = @(0.3);
    glowOuterMostAnimation.toValue = @(0.03);
    glowOuterMostAnimation.duration = 0.3;
    glowOuterMostAnimation.autoreverses = YES;
    glowOuterMostAnimation.repeatCount = HUGE_VALF;
    [self.glowLayerOuterMost addAnimation:glowOuterMostAnimation forKey:@"glowOuterMostAnimation"];
}
- (void)stopGlowAnimation {
    [self.glowLayer removeAnimationForKey:@"glowAnimation"];
    [self.glowLayerOuter removeAnimationForKey:@"glowOuterAnimation"];
    [self.glowLayerOuterMost removeAnimationForKey:@"glowOuterMostAnimation"];
    CABasicAnimation *fadeGlow = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeGlow.fromValue = @(self.glowLayer.opacity); // Giá trị hiện tại
    fadeGlow.toValue = @(0.0); // Mờ dần về 0
    fadeGlow.duration = 0.3; // Thời gian mờ dần: 0.5 giây
    fadeGlow.fillMode = kCAFillModeForwards;
    fadeGlow.removedOnCompletion = NO; // Giữ trạng thái cuối cùng
    [self.glowLayer addAnimation:fadeGlow forKey:@"fadeGlow"];
    CABasicAnimation *fadeOuter = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOuter.fromValue = @(self.glowLayerOuter.opacity);
    fadeOuter.toValue = @(0.0);
    fadeOuter.duration = 0.3;
    fadeOuter.fillMode = kCAFillModeForwards;
    fadeOuter.removedOnCompletion = NO;
    [self.glowLayerOuter addAnimation:fadeOuter forKey:@"fadeOuter"];
    CABasicAnimation *fadeOuterMost = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOuterMost.fromValue = @(self.glowLayerOuterMost.opacity);
    fadeOuterMost.toValue = @(0.0);
    fadeOuterMost.duration = 0.3;
    fadeOuterMost.fillMode = kCAFillModeForwards;
    fadeOuterMost.removedOnCompletion = NO;
    [self.glowLayerOuterMost addAnimation:fadeOuterMost forKey:@"fadeOuterMost"];

    timer(0.3) 
    {
        self.glowLayer.hidden = YES;
        self.glowLayerOuter.hidden = YES;
        self.glowLayerOuterMost.hidden = YES;
        self.glowLayer.opacity = 1.0;
        self.glowLayerOuter.opacity = 0.3;
        self.glowLayerOuterMost.opacity = 0.15;
        [self.glowLayer removeAnimationForKey:@"fadeGlow"];
        [self.glowLayerOuter removeAnimationForKey:@"fadeOuter"];
        [self.glowLayerOuterMost removeAnimationForKey:@"fadeOuterMost"];
    });
}

- (void)setupMenuComponents 
{
    // Khởi tạo menu icon, fps, nền
    UIView *mainView = [UIApplication sharedApplication].windows[0].rootViewController.view;
    hideRecordTextfield = [[UITextField alloc] init];
    hideRecordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    [hideRecordView setBackgroundColor:[UIColor clearColor]];
    [hideRecordView setUserInteractionEnabled:YES];
    hideRecordTextfield.secureTextEntry = true;
    [hideRecordView addSubview:hideRecordTextfield];
    CALayer *layer = hideRecordTextfield.layer;

    if ([layer.sublayers.firstObject.delegate isKindOfClass:[UIView class]]) {
        hideRecordView = (UIView *)layer.sublayers.firstObject.delegate;
    } else {
        hideRecordView = nil;
    }

    [[UIApplication sharedApplication].keyWindow addSubview:hideRecordView];

    if (!_vna) {
        ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
        _vna = vc;
    }

    [ImGuiDrawView showChange:false];
    [hideRecordView addSubview:_vna.view];

    menuTouchView = [[MenuInteraction alloc] initWithFrame:mainView.frame];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:menuTouchView];



    // Mã hoá thuật toán mạnh hơn (AES) tránh tình trạng Crack url binary
    const char originalURL[] = "https://img.upanh.tv/2025/04/20/Logo-DL.png";
    auto encryptedURL = _lxy_oxor_any_::oxor_any<char, sizeof(originalURL) / sizeof(char), __COUNTER__>(originalURL, _lxy_::make_index_sequence<sizeof(originalURL)>());
    const char *decryptedURL = encryptedURL.get();
    NSString *urlString = [NSString stringWithUTF8String:decryptedURL];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    UIImage *menuIconImage = [UIImage imageWithData:data]; // Icon hình ảnh


    // // Lấy icon cụ thể từ bundle (tên file: icon.png, icon@2x.png, icon@3x.png)
    // UIImage *menuIconImage = nil;
    // NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
    // NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary]; // Khai báo infoDict ở đây để dùng xuyên suốt
    // // Ưu tiên lấy icon@3x.png (độ phân giải cao nhất)
    // NSString *icon3xPath = [bundlePath stringByAppendingPathComponent:@"icon@3x.png"];
    // if ([[NSFileManager defaultManager] fileExistsAtPath:icon3xPath]) {
    //     menuIconImage = [UIImage imageWithContentsOfFile:icon3xPath];
    // }
    // // Nếu không có @3x, lấy icon@2x.png
    // if (!menuIconImage) {
    //     NSString *icon2xPath = [bundlePath stringByAppendingPathComponent:@"icon@2x.png"];
    //     if ([[NSFileManager defaultManager] fileExistsAtPath:icon2xPath]) {
    //         menuIconImage = [UIImage imageWithContentsOfFile:icon2xPath];
    //     }
    // }
    // // Nếu không có @2x, lấy icon.png
    // if (!menuIconImage) {
    //     NSString *iconPath = [bundlePath stringByAppendingPathComponent:@"icon.png"];
    //     if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
    //         menuIconImage = [UIImage imageWithContentsOfFile:iconPath];
    //     }
    // }
    // // Fallback nếu không tìm thấy các file icon cụ thể
    // if (!menuIconImage) {
    //     NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    //     NSDictionary *iconsDict = infoDict[@"CFBundleIcons"][@"CFBundlePrimaryIcon"];
    //     NSArray *iconFiles = iconsDict[@"CFBundleIconFiles"];
    //     NSString *iconFileName = iconFiles.firstObject;
    //     if (iconFileName) {
    //         menuIconImage = [UIImage imageNamed:iconFileName];
    //     }
    // }
    // if (!menuIconImage) {
    //     NSString *iconName = infoDict[@"CFBundleIconName"];
    //     if (iconName) {
    //         menuIconImage = [UIImage imageNamed:iconName];
    //     }
    // }
    // if (!menuIconImage) {
    //     menuIconImage = [UIImage imageNamed:@"AppIcon"];
    // }

    // if (!menuIconImage) {
    //     menuIconImage = [UIImage systemImageNamed:@"app.fill"]; // Icon mặc định từ SF Symbols
    // }

    // Khởi tạo menuBackground
    menuBackground = [[UIView alloc] initWithFrame:CGRectMake(65, 65, 110, 50)]; // Điều chỉnh từ (5, 5) sang (65, 65)
    menuBackground.backgroundColor = [UIColor clearColor];
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat radius = 25.0;
    CGFloat width = 110.0;
    CGFloat height = 50.0;
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(width - radius, 0)];
    [path addArcWithCenter:CGPointMake(width - radius, radius) radius:radius startAngle:3 * M_PI / 2 endAngle:M_PI / 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(radius, height)];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI / 2 endAngle:3 * M_PI / 2 clockwise:YES];
    [path closePath];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.7].CGColor;
    [menuBackground.layer addSublayer:shapeLayer];
    shapeLayer.frame = menuBackground.bounds;
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:menuBackground];


    // Khởi tạo glowLayer (viền chính)
    self.glowLayer = [CAShapeLayer layer];
    self.glowLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 110, 50) cornerRadius:25].CGPath;
    self.glowLayer.fillColor = [UIColor clearColor].CGColor;
    self.glowLayer.strokeColor = [UIColor cyanColor].CGColor;
    self.glowLayer.lineWidth = 1.5;
    self.glowLayer.shadowColor = [UIColor cyanColor].CGColor;
    self.glowLayer.shadowRadius = 10.0;
    self.glowLayer.shadowOpacity = 0.8;
    self.glowLayer.shadowOffset = CGSizeZero;
    self.glowLayer.frame = menuBackground.bounds;
    [menuBackground.layer addSublayer:self.glowLayer];
    self.glowLayer.hidden = YES;

    // Khởi tạo glowLayerOuter (viền ngoài thứ nhất)
    self.glowLayerOuter = [CAShapeLayer layer];
    self.glowLayerOuter.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-2, -2, 114, 54) cornerRadius:27].CGPath;
    self.glowLayerOuter.fillColor = [UIColor clearColor].CGColor;
    self.glowLayerOuter.strokeColor = [UIColor cyanColor].CGColor;
    self.glowLayerOuter.lineWidth = 2.0;
    self.glowLayerOuter.opacity = 0.3;
    self.glowLayerOuter.shadowColor = [UIColor cyanColor].CGColor;
    self.glowLayerOuter.shadowRadius = 15.0;
    self.glowLayerOuter.shadowOpacity = 0.5;
    self.glowLayerOuter.shadowOffset = CGSizeZero;
    self.glowLayerOuter.frame = menuBackground.bounds;
    [menuBackground.layer addSublayer:self.glowLayerOuter];
    self.glowLayerOuter.hidden = YES;

    // Khởi tạo glowLayerOuterMost (viền ngoài thứ hai - mới)
    self.glowLayerOuterMost = [CAShapeLayer layer];
    self.glowLayerOuterMost.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-4, -4, 118, 58) cornerRadius:29].CGPath; // Lớn hơn nữa
    self.glowLayerOuterMost.fillColor = [UIColor clearColor].CGColor;
    self.glowLayerOuterMost.strokeColor = [UIColor cyanColor].CGColor;
    self.glowLayerOuterMost.lineWidth = 2.5; // Hơi dày hơn để tỏa sáng rõ
    self.glowLayerOuterMost.opacity = 0.15; // Rất mờ (15% độ đậm)
    self.glowLayerOuterMost.shadowColor = [UIColor cyanColor].CGColor;
    self.glowLayerOuterMost.shadowRadius = 20.0; // Tỏa sáng rộng hơn nữa
    self.glowLayerOuterMost.shadowOpacity = 0.3; // Ánh sáng rất mờ
    self.glowLayerOuterMost.shadowOffset = CGSizeZero;
    self.glowLayerOuterMost.frame = menuBackground.bounds;
    [menuBackground.layer addSublayer:self.glowLayerOuterMost];
    self.glowLayerOuterMost.hidden = YES;


    // Khởi tạo InvisibleMenuButton với kích thước bao trùm
    InvisibleMenuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    InvisibleMenuButton.frame = CGRectMake(70, 70, 110, 50); // Đã thay đổi từ (10, 10) sang (70, 70)
    InvisibleMenuButton.backgroundColor = [UIColor clearColor];
    [InvisibleMenuButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [InvisibleMenuButton addGestureRecognizer:tapGestureRecognizer];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:InvisibleMenuButton];

    // Khởi tạo VisibleMenuButton
    VisibleMenuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    VisibleMenuButton.frame = CGRectMake(70, 70, 40, 40); // Đã thay đổi từ (10, 10) sang (70, 70)
    VisibleMenuButton.backgroundColor = [UIColor clearColor];
    VisibleMenuButton.layer.cornerRadius = VisibleMenuButton.frame.size.width * 0.5f;
    [VisibleMenuButton setBackgroundImage:menuIconImage forState:UIControlStateNormal];
    VisibleMenuButton.layer.borderColor = [UIColor whiteColor].CGColor;
    VisibleMenuButton.layer.borderWidth = 1.0f;
    VisibleMenuButton.clipsToBounds = YES;
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:VisibleMenuButton];
    [VisibleMenuButton setUserInteractionEnabled:NO];
    [VisibleMenuButton layoutIfNeeded];

    // Nút tầm ngắm - Chỉ hiển thị nếu NutNgam == true
    // if (NutNgam) {
    // // Nút tầm ngắm
    // self.circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // self.circleButton.frame = CGRectMake(circleX - iconSize / 2, circleY - iconSize / 2, iconSize, iconSize);
    // self.circleButton.layer.cornerRadius = iconSize / 2;
    // self.circleButton.clipsToBounds = YES;
    // self.circleButton.layer.borderColor = [UIColor greenColor].CGColor;
    // self.circleButton.layer.borderWidth = 2.0f;

    // NSURL *imageURL = [NSURL URLWithString:@"https://img.upanh.tv/2025/04/04/tam-ngam.png"];
    // NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    // UIImage *circleImage = nil;
    // if (imageData) {
    //     circleImage = [UIImage imageWithData:imageData];
    // } else {
    //     circleImage = [UIImage systemImageNamed:@"exclamationmark.triangle"];
    // }
    // [self.circleButton setBackgroundImage:circleImage forState:UIControlStateNormal];

    // self.overlayView = [[UIView alloc] initWithFrame:self.circleButton.bounds];
    // self.overlayView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.39];
    // self.overlayView.layer.cornerRadius = iconSize / 2;
    // self.overlayView.hidden = YES;
    // [self.circleButton addSubview:self.overlayView];

    // [self.circleButton addTarget:self action:@selector(circleButtonTouched:) forControlEvents:UIControlEventTouchDown];
    // [self.circleButton addTarget:self action:@selector(circleButtonReleased:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

    // [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:self.circleButton];
    // [[UIApplication sharedApplication].windows[0].rootViewController.view bringSubviewToFront:self.circleButton];
    // // Hết nút ngắm
    // }

    // Khởi tạo FPS Label
    fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 80, 50, 20)]; // Điều chỉnh từ (55, 15) sang (115, 80)
    fpsLabel.backgroundColor = [UIColor clearColor];
    fpsLabel.textAlignment = NSTextAlignmentCenter;
    fpsLabel.font = [UIFont systemFontOfSize:13];
    fpsLabel.text = @"0 fps";
    NSMutableAttributedString *fpsText = [[NSMutableAttributedString alloc] initWithString:fpsLabel.text];
    [fpsText addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, 1)];
    [fpsText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(2, 3)];
    fpsLabel.attributedText = fpsText;
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:fpsLabel];

    // Đưa InvisibleMenuButton lên trên cùng để nhận sự kiện
    [[UIApplication sharedApplication].windows[0].rootViewController.view bringSubviewToFront:InvisibleMenuButton];
    [[UIApplication sharedApplication].windows[0].rootViewController.view bringSubviewToFront:VisibleMenuButton];
    [[UIApplication sharedApplication].windows[0].rootViewController.view bringSubviewToFront:fpsLabel];

    // Thêm logic ẩn/hiện icon menu
    [self setupGestureRecognizers];
    // Bắt đầu cập nhật FPS
    [self startFPSUpdate];

    [self showMenu];
    [self closeMenu];
}

- (void)startFPSUpdate {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFPS:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)updateFPS:(CADisplayLink *)displayLink {
    ImGuiIO& io = ImGui::GetIO();
    NSString *fpsString = [NSString stringWithFormat:@"%d fps", (int)io.Framerate]; // Đổi lại thành %d và thêm (int) // INT
    // NSString *fpsString = [NSString stringWithFormat:@"%.1f fps", io.Framerate]; // Đổi %d thành %.1f, bỏ (int) // FLOAT
    NSMutableAttributedString *fpsText = [[NSMutableAttributedString alloc] initWithString:fpsString];
    [fpsText addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, fpsString.length - 4)]; // Số màu xanh lá
    [fpsText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(fpsString.length - 4, 4)]; // " fps" màu trắng
    fpsLabel.attributedText = fpsText;
}


// Thêm các gesture để ẩn/hiện icon menu
- (void)setupGestureRecognizers 
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    // Gesture ẩn icon: chạm 3 ngón 2 lần
    UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenuIcon:)];
    hideTap.numberOfTapsRequired = 2; // 2 lần chạm
    hideTap.numberOfTouchesRequired = 3; // 3 ngón tay
    [window addGestureRecognizer:hideTap];

    // Gesture hiện icon: chạm 2 ngón 2 lần
    UITapGestureRecognizer *showTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuIcon:)];
    showTap.numberOfTapsRequired = 2; // 2 lần chạm
    showTap.numberOfTouchesRequired = 2; // 2 ngón tay
    [window addGestureRecognizer:showTap];
}

// Hàm xử lý chạm vào icon để mở/đóng menu
- (void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer 
{
    if(tapGestureRecognizer.state == UIGestureRecognizerStateEnded) 
    {
        [ImGuiDrawView showChange:![ImGuiDrawView isMenuShowing]];

        [self startGlowAnimation]; // Bật hiệu ứng
        timer(0.3) 
        {
            [self stopGlowAnimation]; // Tắt sau 0.3 giây
        });

    }
}

// Hàm ẩn icon menu
- (void)hideMenuIcon:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        InvisibleMenuButton.hidden = YES;
        VisibleMenuButton.hidden = YES;
        menuBackground.hidden = YES;
        fpsLabel.hidden = YES;
    }
}

- (void)showMenuIcon:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        InvisibleMenuButton.hidden = NO;
        VisibleMenuButton.hidden = NO;
        menuBackground.hidden = NO;
        fpsLabel.hidden = NO;
    }
}

// Hàm hiển thị menu
- (void)showMenu 
{
    [ImGuiDrawView showChange:true];
}

// Hàm đóng menu
- (void)closeMenu 
{
    [ImGuiDrawView showChange:false];
}

- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event 
{
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;

    // Di chuyển InvisibleMenuButton
    button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);

    // Dùng button.frame.origin làm tham chiếu để tính toán vị trí các thành phần
    CGPoint origin = button.frame.origin;

    // Di chuyển menuBackground (giữ nguyên kích thước 110x50)
    menuBackground.frame = CGRectMake(origin.x - 5, origin.y - 5, 110, 50);

    // Di chuyển VisibleMenuButton (giữ nguyên kích thước 40x40)
    VisibleMenuButton.frame = CGRectMake(origin.x, origin.y, 40, 40);

    // Di chuyển FPS Label (giữ nguyên kích thước 50x20)
    fpsLabel.frame = CGRectMake(origin.x + 45, origin.y + 10, 50, 20);

    // Bật hiệu ứng khi kéo
    [self startGlowAnimation];

}



// - (void)circleButtonTouched:(UIButton *)sender 
// {
//     self.overlayView.hidden = NO; // Hiện lớp phủ đỏ
//     mua = true;               // Gọi hàm FloMua với trạng thái true
// }

// - (void)circleButtonReleased:(UIButton *)sender 
// {
//     self.overlayView.hidden = YES; // Ẩn lớp phủ đỏ
//     mua = false;               // Gọi hàm FloMua với trạng thái false
// }




- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event 
{
    [self stopGlowAnimation]; // Tắt hiệu ứng khi thả tay
}

@end

