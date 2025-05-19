ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
IGNORE_WARNINGS = 1
TARGET = iphone:clang:latest:14.0
THEOS = /home/cbe/theos/

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DynamicLeak

LOADVIEW_SRC = $(wildcard LoadView/*.mm) $(wildcard LoadView/*.m) $(wildcard LoadView/Support/*.m) $(wildcard Security/*.cpp) 
IMGUI_SRC = $(wildcard imgui/*.cpp) $(wildcard imgui/*.mm)
MYLIB_SRC = $(wildcard Lib/*.mm) $(wildcard Lib/*.m) $(wildcard Lib/*.cpp) $(wildcard Lib/*.c) 
MyHook_SRC = $(wildcard Unity/*.a)
Loading_SRC = $(wildcard LoadView/Loading/*.m)
$(TWEAK_NAME)_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -fvisibility=hidden -fexceptions
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -fvisibility=hidden 

# Add Lib
$(TWEAK_NAME)_LDFLAGS = $(MyHook_SRC) 

ifeq ($(IGNORE_WARNINGS),1)
  $(TWEAK_NAME)_CFLAGS += -w
  $(TWEAK_NAME)_CCFLAGS += -w
endif

$(TWEAK_NAME)_FILES = Main.mm $(Cbeios_RESOURCE_FILES) $(LOADVIEW_SRC) $(IMGUI_SRC) $(MYLIB_SRC) $(Loading_SRC) 
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation UniformTypeIdentifiers Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController UIKit SafariServices Accelerate Foundation QuartzCore CoreGraphics AudioToolbox CoreText Metal MobileCoreServices Security SystemConfiguration IOKit CoreTelephony CoreImage CFNetwork AdSupport AVFoundation
$(TWEAK_NAME)_DEFAULT_GENERATOR = internal 
include $(THEOS_MAKE_PATH)/tweak.mk