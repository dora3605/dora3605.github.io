#import "Config/include.h"
#include "Unity/IncludeHook.h"
#include <mach-o/dyld.h>
NSMutableArray *hookedOffsets;
static NSMutableArray *hardwareHookedOffsets;
static NSMutableArray *hookOffsetsList;
#define STATIC_HOOK_CODEPAGE_SIZE 0x1000
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
#pragma GCC diagnostic ignored "-Wunused-function"
#pragma GCC diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-W#warnings"
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wreorder"
#pragma GCC diagnostic ignored "-Wwritable-strings"
#pragma GCC diagnostic ignored "-Wtrigraphs"
typedef struct 
{
    uint64_t hook_vaddr;
    uint64_t hook_size;
    uint64_t code_vaddr;
    uint64_t code_size;
    uint64_t patched_vaddr;
    uint64_t original_vaddr;
    uint64_t instrument_vaddr;
    uint64_t patch_size;
    uint64_t patch_hash;
    void *target_replace;
    void *instrument_handler;
} StaticInlineHookBlock;
uint64_t va2rva(struct mach_header_64 *header, uint64_t va) 
{
    uint64_t rva = va;
    uint64_t header_vaddr = -1;
    struct load_command *lc = (struct load_command *)((uint64_t)header + sizeof(*header));
    for (int i = 0; i < header->ncmds; i++) 
    {
    if (lc->cmd == LC_SEGMENT_64) {
    struct segment_command_64 *seg = (struct segment_command_64 *)lc;
    if (seg->fileoff == 0 && seg->filesize > 0) 
    {
    if (header_vaddr != -1) 
    {
    return 0;
    }
    header_vaddr = seg->vmaddr;
    }
    }
    lc = (struct load_command *)((char *)lc + lc->cmdsize);
    }
    if (header_vaddr != -1) 
    {
    rva -= header_vaddr;
    }
    return rva;
}
uint64_t getAnogsBaseAddress() 
{
    const char* targetFramework = oxorany("anogs.framework/anogs"); 
    for (int i = 0; i < _dyld_image_count(); i++) 
    {
    const char* image_name = _dyld_get_image_name(i);
    if (image_name && strstr(image_name, targetFramework)) 
    {
    return (uint64_t)_dyld_get_image_header(i); 
    }
    }
    return 0;
}
uint64_t getUnityFrameworkBase() 
{
    MemoryInfo info = getBaseAddress(oxorany("UnityFramework"));
    return (uint64_t)info.address;
}
@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, assign) int selectedLanguage;
@property (nonatomic, assign) BOOL hasShownAimSkillGuide; 
@end
UIView *view;
NSFileManager *fileManager1 = [NSFileManager defaultManager];
NSUserDefaults *saveSetting = [NSUserDefaults standardUserDefaults];
NSString *documentDir1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
@implementation ImGuiDrawView
ImFont* _espFont;
ImFont *_iconFont;
ImFont* _ESPFONT; 
ImFont* _smallFont; 
ImFont* _CMDFont; 
static bool MenDeal = false;
static bool toggle = false;
static bool StreamerMode = false;
void SliderFloatCus(const char* label, float* v, float v_min, float v_max, const char* format) {
    ImGuiIO& io = ImGui::GetIO();
    ImGuiStyle& style = ImGui::GetStyle();
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 pos = ImGui::GetCursorScreenPos();
    float width = ImGui::CalcItemWidth() - 10.0f;
    float track_height = 4.0f;
    float handle_radius = 7.0f;
    ImVec2 size(width, handle_radius * 2.0f);
    pos.x += 5.0f;
    ImGui::InvisibleButton(label, size);
    bool is_active = ImGui::IsItemActive();
    bool is_hovered = ImGui::IsItemHovered();
    float t = (*v - v_min) / (v_max - v_min);
    t = ImClamp(t, 0.0f, 1.0f);
    if (is_active && io.MouseDelta.x != 0.0f) 
    {
        float delta = io.MouseDelta.x / width;
        t += delta;
        t = ImClamp(t, 0.0f, 1.0f);
        *v = v_min + t * (v_max - v_min);
        ImGui::MarkItemEdited(ImGui::GetID(label)); 
    }
    float handle_pos_x = pos.x + t * width;
    float track_y = pos.y + handle_radius;
    ImVec2 track_left_p1 = ImVec2(pos.x, track_y);
    ImVec2 track_left_p2 = ImVec2(handle_pos_x, track_y);
    draw_list->AddLine(track_left_p1, track_left_p2, IM_COL32(255, 209, 0, 255), track_height);
    ImVec2 track_right_p1 = ImVec2(handle_pos_x, track_y);
    ImVec2 track_right_p2 = ImVec2(pos.x + width, track_y);
    draw_list->AddLine(track_right_p1, track_right_p2, IM_COL32(255, 105, 180, 255), track_height);
    ImU32 handle_col = is_active ? IM_COL32(50, 205, 50, 255) : IM_COL32(0, 0, 0, 255);
    ImU32 border_col = IM_COL32(255, 165, 0, 255);
    draw_list->AddCircleFilled(ImVec2(handle_pos_x, track_y), handle_radius, handle_col, 90);
    draw_list->AddCircle(ImVec2(handle_pos_x, track_y), handle_radius, border_col, 90, 2.0f);
    ImGui::SetCursorScreenPos(ImVec2(pos.x - 5.0f, pos.y + size.y + style.ItemSpacing.y));
}
void IOSCheckbox(const char* label, bool* v, ImGuiDrawView* viewController)
{
    ImGuiIO& io = ImGui::GetIO();
    ImGuiStyle& style = ImGui::GetStyle();
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 pos = ImGui::GetCursorScreenPos();
    float height = 15.0f;
    float width = height * 2.0f;
    float handle_radius = height * 0.45f;
    ImVec2 size(width, height);
    static int toggle_counter = 0;
    ImGui::PushID(toggle_counter++);
    ImGui::InvisibleButton(label, size);
    bool is_active = ImGui::IsItemActive();
    bool is_hovered = ImGui::IsItemHovered();
    ImGuiStorage* storage = ImGui::GetStateStorage();
    ImGuiID id = ImGui::GetID(oxorany("toggle"));
    float t = storage->GetFloat(id, *v ? 1.0f : 0.0f);
    bool animating = storage->GetBool(id + 1, false);
    float target_t = storage->GetFloat(id + 2, *v ? 1.0f : 0.0f);
    static bool lastState = false;
    if (ImGui::IsItemClicked())
    {
    animating = true;
    target_t = *v ? 0.0f : 1.0f;
    *v = !*v;
    storage->SetBool(id + 1, animating);
    storage->SetFloat(id + 2, target_t);

    if (*v && !lastState)
    {
    leakHookOffsets(viewController, v);
    }
    }
    lastState = *v;
    if (animating)
    {
    float speed = 5.0f;
    float delta = io.DeltaTime * speed;
    if (io.DeltaTime < 0.001f) delta = 0.016f * speed;
    if (t < target_t)
    {
    t += delta;
    if (t >= target_t)
    {
    t = target_t;
    animating = false;
    }
    }
    else if (t > target_t)
    {
    t -= delta;
    if (t <= target_t)
    {
    t = target_t;
    animating = false;
    }
    }
    float eased_t = 1.0f - powf(1.0f - t, 3.0f);
    storage->SetFloat(id, eased_t);
    storage->SetBool(id + 1, animating);
    t = eased_t;
    }
    float handle_pos_x = pos.x + handle_radius + 1.0f + t * (width - 2.0f * (handle_radius + 1.0f));
    ImVec2 track_p1 = ImVec2(pos.x, pos.y);
    ImVec2 track_p2 = ImVec2(pos.x + width, pos.y + height);
    ImU32 track_col = *v ? IM_COL32(30, 144, 255, 255) : IM_COL32(128, 128, 128, 255);
    draw_list->AddRectFilled(track_p1, track_p2, track_col, height * 0.5f);
    ImU32 handle_col = IM_COL32(255, 255, 255, 255);
    ImU32 border_col = *v ? IM_COL32(30, 144, 255, 255) : IM_COL32(128, 128, 128, 255);
    draw_list->AddCircleFilled(ImVec2(handle_pos_x, pos.y + height / 2.0f), handle_radius, handle_col, 90);
    draw_list->AddCircle(ImVec2(handle_pos_x, pos.y + height / 2.0f), handle_radius, border_col, 90, 1.0f);
    ImVec2 text_pos = ImVec2(pos.x + width + style.ItemSpacing.x, pos.y + (height - ImGui::GetTextLineHeight()) / 2.0f);
    draw_list->AddText(text_pos, IM_COL32(255, 255, 255, 255), label);
    ImGui::SetCursorScreenPos(ImVec2(pos.x, pos.y + height + style.ItemSpacing.y));
    ImGui::PopID();
}
void collectHookOffsets()
{
    hookedOffsets = [NSMutableArray new];
    for (int i = 0; i < _dyld_image_count(); i++) 
    {
        const char *image_name = _dyld_get_image_name(i);
        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(i);
        if (!header || !image_name) continue;
        struct segment_command_64 *data_seg = NULL;
        struct load_command *lc = (struct load_command *)((uint64_t)header + sizeof(*header));
        for (int j = 0; j < header->ncmds; j++) {
        if (lc->cmd == LC_SEGMENT_64) {
        struct segment_command_64 *seg = (struct segment_command_64 *)lc;
        if (strcmp(seg->segname, "__HOOK_DATA") == 0 ||
        strcmp(seg->segname, "__HOOK_VA") == 0 ||
        strcmp(seg->segname, "__PP_OFFSETS") == 0 ||
        strcmp(seg->segname, "__PP_BYTESVA") == 0) {
        data_seg = seg;
        break;
        }
        }
        lc = (struct load_command *)((char *)lc + lc->cmdsize);
        }
        if (!data_seg) continue;
        StaticInlineHookBlock *hookBlock = (StaticInlineHookBlock *)((uint64_t)header + va2rva((struct mach_header_64 *)header, data_seg->vmaddr));
        if (!hookBlock) continue;
        for (int k = 0; k < STATIC_HOOK_CODEPAGE_SIZE / sizeof(StaticInlineHookBlock); k++) 
        {
        if (hookBlock[k].hook_vaddr == 0) break;
        uint64_t hook_va = hookBlock[k].hook_vaddr;
        uint64_t patch_size = hookBlock[k].patch_size;
        bool isActive = (hookBlock[k].target_replace != NULL);
        NSString *status = isActive ? @"✔ Activated" : @"⭕ Not activated";
        void *patchedData = (void *)((uint64_t)header + va2rva((struct mach_header_64 *)header, hookBlock[k].patched_vaddr));
        if (!patchedData) continue;
        NSMutableString *patchBytesStr = [NSMutableString string];
        uint8_t *patchBytes = (uint8_t *)patchedData;
        for (int j = 0; j < patch_size; j++) {
        [patchBytesStr appendFormat:@"%02X ", patchBytes[j]]; 
        }
        NSString *frameworkName = [[NSString stringWithUTF8String:image_name] lastPathComponent];
        [hookedOffsets addObject:[NSString stringWithFormat:@"Module: %@\nOffset: 0x%llX\nPatch size: %llu bytes\nPatch bytes: %@\nStatus: %@\n-------------------------------",
        frameworkName, hook_va, patch_size, patchBytesStr, status]]; 
        }
    }
}
void leakHookOffsets(ImGuiDrawView* viewController, bool* toggleState)
{
    collectHookOffsets(); 
    dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alert;
    if (!hookedOffsets.count) 
    {
    alert = [UIAlertController alertControllerWithTitle:@"Notification"
    message:@"> Error: No hooks found. Check module or framework..."
    preferredStyle:UIAlertControllerStyleAlert];
    } 
    else 
    {
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/Leak.txt", NSHomeDirectory()];
    NSString *content = [hookedOffsets componentsJoinedByString:@"\n"];
    NSString *fullContent = [NSString stringWithFormat:@"Dynamic Leak: List Offset\n\n%@\n\nCreated by cbeios - t.me/cbeios", content];
    NSError *error = nil;
    BOOL success = [fullContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (success) {
    alert = [UIAlertController alertControllerWithTitle:@"Successfully !!!"
    message:[NSString stringWithFormat:@"Offsets have been saved at output:\n%@", filePath]
    preferredStyle:UIAlertControllerStyleAlert];
    } else {
    alert = [UIAlertController alertControllerWithTitle:@"Error !!!"
    message:[NSString stringWithFormat:@"Unable to save file: %@", error.localizedDescription]
    preferredStyle:UIAlertControllerStyleAlert];
    }
    }
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@" Ok " style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    *toggleState = false; 
    }];
    [alert addAction:ok];
    [viewController presentViewController:alert animated:YES completion:nil];
    });
}
void TextBuild(ImGuiDrawView* cbeios) 
{
    ImGui::PushFont(_smallFont); 
    ImGui::TextColored(ImVec4(0.7843f, 0.7843f, 0.7843f, 0.7843f), oxorany("                                         Build package : 20/04/2025"));
    ImGui::PopFont();
}
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    if (!_device) abort();
    _selectedLanguage = 0; 
    _hasShownAimSkillGuide = false; 
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    ImGui::StyleColorsDark(); // Menu tối
    ImGuiStyle &style = ImGui::GetStyle();
    style.WindowPadding = ImVec2(10, 10);
    style.WindowRounding = 10.0f; // Thay đổi giá trị này để điều chỉnh độ bo tròn góc của menu
    style.FramePadding = ImVec2(5, 5);
    style.FrameRounding = 3.0f; // Độ bo tròn cho khung (nếu mày có khung)
    style.ItemSpacing = ImVec2(12, 8);
    style.ItemInnerSpacing = ImVec2(8, 6);
    style.IndentSpacing = 25.0f;
    style.ScrollbarSize = 15.0f;
    style.ScrollbarRounding = 9.0f;
    style.GrabMinSize = 5.0f;
    style.GrabRounding = 3.0f;
    style.WindowBorderSize = 0.0f; // // Không có viền mặc định
    style.FrameBorderSize = 0.1f;
    style.PopupBorderSize = 0.1f;
    style.Alpha = 1.0f;
    ImVec4 *colors = ImGui::GetStyle().Colors;
    colors[ImGuiCol_Text] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f); // Màu trắng cho văn bản menu
    colors[ImGuiCol_TextDisabled] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f); // Màu trắng cho văn bản bị vô hiệu hóa
    float alpha = 230.0f / 255.0f; // Chỉnh alpha màu nền cho menu
    colors[ImGuiCol_WindowBg] = ImVec4(0.0f, 0.0f, 0.0f, alpha); // Màu đen với alpha 180
    colors[ImGuiCol_ChildBg] = ImVec4(0.0f, 0.0f, 0.0f, alpha); // Màu đen với alpha 180 cho nền con
    colors[ImGuiCol_PopupBg] = ImVec4(0.0f, 0.0f, 0.0f, alpha); // Màu đen với alpha 180 cho nền popup
    colors[ImGuiCol_Border] = ImVec4(0.0f, 0.0f, 0.0f, 1.0f); // Màu đen cho đường viền
    colors[ImGuiCol_CheckMark] = ImVec4(135.0f / 255.0f, 206.0f / 255.0f, 235.0f / 255.0f, 1.0f); // Màu xanh sky blue sáng
    ImFontConfig config;
    ImFontConfig icons_config;
    config.FontDataOwnedByAtlas = false;
    icons_config.MergeMode = true;
    icons_config.PixelSnapH = true;
    icons_config.OversampleH = 2;
    icons_config.OversampleV = 2;
    static const ImWchar icons_ranges[] = {0xf000, 0xf3ff, 0};
    NSString *fontPath = @"/System/Library/Fonts/Core/AvenirNext.ttc";
    _espFont = io.Fonts->AddFontFromFileTTF(fontPath.UTF8String, 45.0f, &config, io.Fonts->GetGlyphRangesVietnamese());
    _iconFont = io.Fonts->AddFontFromMemoryCompressedTTF(font_awesome_data, font_awesome_size, 30.0f, &icons_config, icons_ranges);
    ImFontConfig ESP_config;
    ESP_config.FontDataOwnedByAtlas = false;
    _ESPFONT = io.Fonts->AddFontFromFileTTF(fontPath.UTF8String, 42.0f, &ESP_config, io.Fonts->GetGlyphRangesVietnamese());
    // Thêm font nhỏ hơn
    ImFontConfig small_config;
    // Thêm font lớn hơn
    ImFontConfig CMD_config;
    small_config.FontDataOwnedByAtlas = false;
    _smallFont = io.Fonts->AddFontFromFileTTF(fontPath.UTF8String, 30.5f, &small_config, io.Fonts->GetGlyphRangesVietnamese());
    _CMDFont = io.Fonts->AddFontFromFileTTF(fontPath.UTF8String, 35.5f, &CMD_config, io.Fonts->GetGlyphRangesVietnamese());
    _iconFont->FontSize = 5;
    io.FontGlobalScale = 0.35f; // scale toàn cục
    ImGui_ImplMetal_Init(_device);
    return self;
}
+ (void)showChange:(BOOL)open 
{
    MenDeal = open;
}
+ (BOOL)isMenuShowing 
{
    return MenDeal;
}
- (MTKView *)mtkView 
{
    return (MTKView *)self.view;
}
- (void)loadView 
{
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}
- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.mtkView.device = self.device;
    if (!self.mtkView.device) 
    {
        return;
    }
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
}
- (void)drawInMTKView:(MTKView *)view 
{
    hideRecordTextfield.secureTextEntry = StreamerMode;
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    if (iPhonePlus) 
    {
        io.DisplayFramebufferScale = ImVec2(2.60, 2.60);
    } 
    else 
    {
        io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    }
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 120);
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    static id<MTLTexture> bg_texture = nil;
    if (bg_texture == nil) {
        NSString *base64String = lqmbconfig;
        std::string base64_std_string([base64String UTF8String]);
        bg_texture = LoadTextureFromBase64(self.device, base64_std_string);
    }
    if (MenDeal == true) 
    {
        [self.view setUserInteractionEnabled:YES];
        [self.view.superview setUserInteractionEnabled:YES];
        [menuTouchView setUserInteractionEnabled:YES];
    } 
    else if (MenDeal == false) 
    {
        [self.view setUserInteractionEnabled:NO];
        [self.view.superview setUserInteractionEnabled:NO];
        [menuTouchView setUserInteractionEnabled:NO];
    }
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
    id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder pushDebugGroup:@"ImGui Jane"];
    ImGui_ImplMetal_NewFrame(renderPassDescriptor);
    ImGui::NewFrame();

    CGFloat width = 280; // Ngang
    CGFloat height = 200; // Dọc

    ImGui::SetNextWindowPos(ImVec2((kWidth - width) / 2, (kHeight - height) / 2), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowSize(ImVec2(width, height), ImGuiCond_FirstUseEver);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ });
    if (MenDeal == true) 
    {
        std::string ProccessName = oxorany("Dynamic Leak (Offsets)");
        ImGui::Begin(ProccessName.c_str(), &MenDeal, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse);

        if (ImGui::BeginTabBar(oxorany("MenuTabs"))) 
        {
            if (ImGui::BeginTabItem(oxorany(ICON_FA_EYE "     Main     "))) // TAB 1
            {
                ImGui::Separator(); 

                NSString *safari_localizedShortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:NSSENCRYPT("CFBundleShortVersionString")];
                std::string Version([safari_localizedShortVersion UTF8String]);
                std::string shortVersion; 
                int dotCount = 0; 
                bool gotOneDigit = false; 
                for (char c : Version) { 
                    if (dotCount < 2 || (dotCount == 2 && isdigit(c) && !gotOneDigit)) { 
                        shortVersion += c; 
                        if (dotCount == 2 && isdigit(c)) gotOneDigit = true; 
                    } else if (dotCount >= 3 || (dotCount == 2 && gotOneDigit)) break; 
                    if (c == oxorany('.')) dotCount++; 
                }
                std::string VersionAdd = std::string(oxorany("                                 v")) + shortVersion;
                ImGuiStyle& style = ImGui::GetStyle();
                ImDrawList* draw_list = ImGui::GetWindowDrawList();
                ImVec2 pos = ImGui::GetCursorScreenPos();
                float dot_radius = 5.0f;
                ImVec2 dot_pos = ImVec2(pos.x + dot_radius, pos.y + dot_radius);
                static float time = 0.0f;
                time += ImGui::GetIO().DeltaTime; 
                float fade = (sin(time * 4.0f) + 1.0f) / 2.0f; 
                int green_value = static_cast<int>(50 + fade * 205); 
                int white_alpha = static_cast<int>(30 + fade * 60); 
                draw_list->AddCircle(dot_pos, dot_radius + 1.0f, IM_COL32(255, 255, 255, white_alpha), 100, 5.0f); 
                draw_list->AddCircleFilled(dot_pos, dot_radius, IM_COL32(0, green_value, 0, 255), 100); 
                ImVec2 text_pos = ImVec2(pos.x + dot_radius * 3, pos.y - 2);
                const char* status_text = oxorany("Load successfully");
                draw_list->AddText(text_pos, IM_COL32(255, 255, 255, 255), status_text); 
                ImVec2 text_size = ImGui::CalcTextSize(status_text);
                ImVec2 version_pos = ImVec2(pos.x + dot_radius * 3 + text_size.x + 5, pos.y - 2); 
                const char* version_Auto = VersionAdd.c_str();
                draw_list->AddText(version_pos, IM_COL32(200, 200, 200, 200), version_Auto); 
                ImGui::SetCursorScreenPos(ImVec2(pos.x, pos.y + dot_radius * 2 + style.ItemSpacing.y));

                ImGui::Separator(); 
                ImGui::Spacing();
                ImGui::TextColored(ImVec4(0.7843f, 0.7843f, 0.7843f, 0.7843f), oxorany("Start Runtime Functions Output"));
                ImGui::SameLine(234);
                IOSCheckbox(oxorany(""), &toggle, self);
                ImGui::Spacing();
                ImGui::TextColored(ImVec4(1.0f, 0.5f, 0.5f, 0.7843f), oxorany("Save at: Documents/Leak.txt"));
                TextBuild(self); // "Build package"
                ImGui::Spacing();

                ImGui::EndTabItem();
            }
            if (ImGui::BeginTabItem(oxorany(ICON_FA_KEY "     CS       "))) // TAB 2
            {                                           
                ImGui::PushFont(_CMDFont); // use CMD_Font (PushFont)

                const ImVec4 COLOR_LIME = ImVec4(0.0f, 1.0f, 0.0f, 1.0f);
                ImGui::TextColored(COLOR_LIME, oxorany("Dynamic Leak [IOS v2.9.81] © All rights reserved."));
                ImGui::TextColored(COLOR_LIME, oxorany("Documents:\\>"));
                ImGui::SameLine(73); 
                float time = ImGui::GetTime();
                float alpha = (int)(time * 1.6667f) % 2 == 0 ? 1.0f : 0.0f; 
                ImGui::TextColored(ImVec4(0.0f, 1.0f, 0.0f, alpha), "_");

                static bool runTriggered = false;
                static bool isTypingDone = false;
                static bool hasShownDialog = false;
                static bool justFinishedTyping = false;
                static bool noHooksFound = false; 
                static bool runPending = false; 
                static float runStartTime = 0.0f;
                static std::vector<std::string> displayLines;
                static size_t currentLine = 0;
                static size_t currentChar = 0;
                static float lastCharTime = 0.0f; 
                const float CHAR_DELAY = 0.000025f; 
                const float RUN_DELAY = 0.5f; 

                ImGui::Separator(); 
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.53f, 0.81f, 0.92f, 0.784f));
                if (ImGui::Button(oxorany("        Run Console        ")))
                {
                    runPending = true; 
                    runStartTime = ImGui::GetTime(); 
                }
                ImGui::PopStyleColor();
                if (runPending && ImGui::GetTime() - runStartTime >= RUN_DELAY)
                {
                    runTriggered = true;
                    isTypingDone = false;
                    justFinishedTyping = false; 
                    hasShownDialog = false;
                    noHooksFound = false; 
                    displayLines.clear();
                    currentLine = 0;
                    currentChar = 0;
                    lastCharTime = ImGui::GetTime();
                    collectHookOffsets(); 
                    if (hookedOffsets.count == 0) 
                    {
                        noHooksFound = true; 
                    } 
                    else 
                    {
                        for (NSString *offset in hookedOffsets)
                        {
                            std::string line = [offset UTF8String];
                            if (line.find(oxorany("✔ Activated")) != std::string::npos) {
                                line.replace(line.find(oxorany("Status: ✔ Activated")), 19, oxorany("Status: Active"));
                            } else if (line.find(oxorany("⭕ Not activated")) != std::string::npos) {
                                line.replace(line.find(oxorany("Status: ⭕ Not activated")), 23, oxorany("Status: Cancel"));
                            }
                            displayLines.push_back(line);
                        }
                    }
                    runPending = false; 
                }
                ImGui::SameLine();
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(1.0f, 1.0f, 0.0f, 0.784f));
                if (ImGui::Button(oxorany("        Clear Input       ")))
                {
                    runTriggered = false;
                    isTypingDone = false;
                    justFinishedTyping = false; 
                    hasShownDialog = false;
                    noHooksFound = false; 
                    runPending = false; 
                    [hookedOffsets removeAllObjects]; 
                    displayLines.clear();
                    currentLine = 0;
                    currentChar = 0;
                    lastCharTime = 0.0f;
                }
                ImGui::PopStyleColor();
                ImGui::Separator(); 
                if (runTriggered)
                {
                    ImGui::PushTextWrapPos(0.0f); 
                    std::string currentDisplay;
                    if (noHooksFound) 
                    {
                        ImGui::TextColored(ImVec4(1.0f, 0.0f, 0.0f, 1.0f), oxorany(">")); 
                        ImGui::SameLine();
                        ImGui::TextColored(ImVec4(1.0f, 1.0f, 1.0f, 1.0f), oxorany("Error: No hooks found, check module..."));
                    } else if (!displayLines.empty()) {
                        ImGui::TextColored(ImVec4(0.529f, 0.808f, 0.922f, 1.0f), "==>");
                        ImGui::SameLine();
                        ImGui::TextColored(ImVec4(1.0f, 1.0f, 1.0f, 1.0f), oxorany("Compiling leak offset...")); 
                
                        if (!isTypingDone)
                        {
                            for (size_t i = 0; i < currentLine; ++i)
                            {
                                currentDisplay += displayLines[i] + "\n";
                            }
                            if (currentLine < displayLines.size())
                            {
                                currentDisplay += displayLines[currentLine].substr(0, currentChar);
                                if (ImGui::GetTime() - lastCharTime >= CHAR_DELAY)
                                {
                                    if (currentChar < displayLines[currentLine].size())
                                    {
                                        currentChar++;
                                    }
                                    else if (currentLine < displayLines.size() - 1)
                                    {
                                        currentLine++;
                                        currentChar = 0;
                                    }
                                    else
                                    {
                                        isTypingDone = true; 
                                        justFinishedTyping = true; 
                                    }
                                    lastCharTime = ImGui::GetTime();
                                }
                            }
                            std::vector<std::string> lines;
                            std::string tempLine;
                            for (char c : currentDisplay) {
                                if (c == '\n') {
                                    lines.push_back(tempLine);
                                    tempLine.clear();
                                } else {
                                    tempLine += c;
                                }
                            }
                            if (!tempLine.empty()) {
                                lines.push_back(tempLine);
                            }
                            for (const auto& line : lines) {
                                if (line.find(oxorany("Status: Active")) != std::string::npos) {
                                    std::string prefix = line.substr(0, line.find(oxorany("Active")));
                                    ImGui::TextColored(COLOR_LIME, "%s", prefix.c_str());
                                    ImGui::SameLine(0, 0);
                                    ImGui::TextColored(ImVec4(1.0f, 1.0f, 1.0f, 1.0f), oxorany("Active"));
                                } else if (line.find(oxorany("Status: Cancel")) != std::string::npos) {
                                    std::string prefix = line.substr(0, line.find(oxorany("Cancel")));
                                    ImGui::TextColored(COLOR_LIME, "%s", prefix.c_str());
                                    ImGui::SameLine(0, 0);
                                    ImGui::TextColored(ImVec4(1.0f, 0.0f, 0.0f, 1.0f), oxorany("Cancel"));
                                } else {
                                    ImGui::TextColored(COLOR_LIME, "%s", line.c_str());
                                }
                            }
                            ImGui::SetScrollHereY(1.0f); 
                        }
                        else
                        {
                            for (const auto& line : displayLines)
                            {
                                currentDisplay += line + "\n";
                            }
                            std::vector<std::string> lines;
                            std::string tempLine;
                            for (char c : currentDisplay) {
                                if (c == '\n') {
                                    lines.push_back(tempLine);
                                    tempLine.clear();
                                } else {
                                    tempLine += c;
                                }
                            }
                            if (!tempLine.empty()) {
                                lines.push_back(tempLine);
                            }
                            for (const auto& line : lines) {
                                if (line.find("Status: Active") != std::string::npos) {
                                    std::string prefix = line.substr(0, line.find("Active"));
                                    ImGui::TextColored(COLOR_LIME, "%s", prefix.c_str());
                                    ImGui::SameLine(0, 0);
                                    ImGui::TextColored(ImVec4(1.0f, 1.0f, 1.0f, 1.0f), "Active");
                                } else if (line.find("Status: Cancel") != std::string::npos) {
                                    std::string prefix = line.substr(0, line.find("Cancel"));
                                    ImGui::TextColored(COLOR_LIME, "%s", prefix.c_str());
                                    ImGui::SameLine(0, 0);
                                    ImGui::TextColored(ImVec4(1.0f, 0.0f, 0.0f, 1.0f), "Cancel");
                                } else {
                                    ImGui::TextColored(COLOR_LIME, "%s", line.c_str());
                                }
                            }
                            ImGui::Separator();
                            ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.53f, 0.81f, 0.92f, 0.784f)); 
                            if (ImGui::Button(oxorany("                   Export                   ")))
                            {
                                NSString *filePath = [NSString stringWithFormat:@"%@/Documents/Leak.txt", NSHomeDirectory()];
                                NSString *content = [hookedOffsets componentsJoinedByString:@"\n"];
                                NSString *fullContent = [NSString stringWithFormat:@"%@\n\nCreated by cbeios - t.me/cbeios", content];
                                NSError *error = nil;
                                BOOL success = [fullContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                                UIAlertController *resultAlert;
                                if (success) {
                                resultAlert = [UIAlertController alertControllerWithTitle:@"Successfully !!!"
                                message:[NSString stringWithFormat:@"Offsets have been saved at output:\n%@", filePath]
                                preferredStyle:UIAlertControllerStyleAlert];
                                } else {
                                resultAlert = [UIAlertController alertControllerWithTitle:@"Error !!!"
                                message:[NSString stringWithFormat:@"Unable to save file: %@", error.localizedDescription]
                                preferredStyle:UIAlertControllerStyleAlert];
                                }
                                UIAlertAction *ok = [UIAlertAction actionWithTitle:@" Ok " style:UIAlertActionStyleDefault handler:nil];
                                [resultAlert addAction:ok];
                                [self presentViewController:resultAlert animated:YES completion:nil];
                            }
                            ImGui::PopStyleColor();
                            ImGui::Separator();
                            if (justFinishedTyping)
                            {
                                ImGui::SetScrollHereY(1.0f); 
                                justFinishedTyping = false; 
                            }
                        }
                    }
                    ImGui::PopTextWrapPos();
                }
                ImGui::PopFont(); // restore Font
                ImGui::EndTabItem();
            }
            if (ImGui::BeginTabItem(oxorany(ICON_FA_INFO_CIRCLE "     Info     "))) // TAB 3
            {
                ImGui::Spacing(); 
                ImGui::Spacing(); 
                ImGui::Spacing(); 

                // Created by cbeios 
                static std::string GroupButton = std::string(ICON_FA_TELEGRAM) + oxorany(" Group ");
                static std::string AdminButton = std::string(ICON_FA_TELEGRAM) + oxorany(" Admin ");
                ImGui::PushStyleColor(ImGuiCol_Button, IM_COL32(255, 165, 0, 255)); // BackGr cam
                ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(255, 255, 255, 255)); // Text trắng
                if (ImGui::Button(GroupButton.c_str(), ImVec2(ImGui::GetContentRegionAvail().x, 0.0f))) {
                    std::string Group = oxorany("cbeiosvn"); // encryption string
                    std::string GroupRaw = oxorany("https://t.me/") + Group; // encryption string
                    NSString *GroupLink = @(GroupRaw.c_str()); // Convert string to NSString
                    NSURL *url = [NSURL URLWithString:GroupLink]; // Open url
                    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                    }
                }
                ImGui::PopStyleColor(2);
                ImGui::Spacing();
                ImGui::PushStyleColor(ImGuiCol_Button, IM_COL32(255, 105, 180, 255)); // BackGr hồng sáng
                ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(255, 255, 255, 255));  // Text trắng
                if (ImGui::Button(AdminButton.c_str(), ImVec2(ImGui::GetContentRegionAvail().x, 0.0f))) {
                    std::string Admin = oxorany("cbeios"); // encryption string
                    std::string AdminRaw = oxorany("https://t.me/") + Admin; // encryption string
                    NSString *AdminLink = @(AdminRaw.c_str()); // Convert string to NSString
                    NSURL *url = [NSURL URLWithString:AdminLink]; // Open url
                    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                    }
                }
                ImGui::PopStyleColor(2);

                ImGui::EndTabItem();
            }
            ImGui::EndTabBar();
        }
        ImGui::End();
        ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
        ImGuiWindow* window = ImGui::FindWindowByName(ProccessName.c_str());
        if (window) 
        {
            ImVec2 pos = window->Pos; 
            ImVec2 size = window->Size; 
            ImVec2 p1 = pos; 
            ImVec2 p2 = ImVec2(pos.x + size.x, pos.y + size.y); 
            draw_list->AddRect(p1, p2, IM_COL32(255, 255, 255, 200), 10.0f, ImDrawFlags_RoundCornersAll, 2.0f);
        }
    }

    ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
    ImGui::Render();
    ImDrawData* draw_data = ImGui::GetDrawData();
    ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
    [renderEncoder popDebugGroup];
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}
- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {}
- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}
ImDrawList* getDrawList() 
{
 ImDrawList *drawList;
 drawList = ImGui::GetBackgroundDrawList();
 return drawList;
};

@end