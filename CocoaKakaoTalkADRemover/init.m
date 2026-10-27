//
//  init.m
//  CocoaKakaoTalkADRemover
//
//  Created by Jinwoo Kim on 10/27/26.
//

#import <AppKit/AppKit.h>
#include <objc/runtime.h>
#include <objc/message.h>

static IMP _Nullable originalViewDidLoad;

static id _Nullable outlet(id object, SEL _cmd) {
    return [object respondsToSelector:_cmd] ? ((id (*)(id, SEL))objc_msgSend)(object, _cmd) : nil;
}

static void customViewDidLoad(__kindof NSViewController *self, SEL _cmd) {
    if (originalViewDidLoad == NULL) return;
    ((void (*)(id, SEL))originalViewDidLoad)(self, _cmd);
    
    NSView * _Nullable advertiseContainerView = outlet(self, sel_registerName("advertiseContainerView"));
    NSView * _Nullable adSeparator = outlet(self, sel_registerName("adSeparator"));
    NSLayoutConstraint * _Nullable advertiseContainerHeightConstraint = outlet(self, sel_registerName("advertiseContainerHeightConstraint"));
    NSLayoutConstraint * _Nullable adSeparatorHeightConstraint = outlet(self, sel_registerName("adSeparatorHeightConstraint"));
    
    if ([advertiseContainerView isKindOfClass:[NSView class]]) {
        advertiseContainerView.hidden = YES;
    }
    
    if ([adSeparator isKindOfClass:[NSView class]]) {
        adSeparator.hidden = YES;
    }
    
    if ([advertiseContainerHeightConstraint isKindOfClass:[NSLayoutConstraint class]]) {
        advertiseContainerHeightConstraint.constant = 0;
    }
    
    if ([adSeparatorHeightConstraint isKindOfClass:[NSLayoutConstraint class]]) {
        adSeparatorHeightConstraint.constant = 0;
    }
}

__attribute__((constructor)) static void init(void) {
    @autoreleasepool {
        Class controller = objc_lookUpClass("_TtC9KakaoTalk20FSMainViewController");
        if (controller == NULL) return;
        
        Method method = class_getInstanceMethod(controller, @selector(viewDidLoad));
        if (method == NULL) return;
        
        originalViewDidLoad = method_getImplementation(method);
        method_setImplementation(method, (IMP)customViewDidLoad);
    }
}
