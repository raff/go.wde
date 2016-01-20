//
//  gmd.c
//  gomacdraw
//
//  Created by John Asmuth on 5/9/11.
//  Copyright 2011 Rutgers University. All rights reserved.
//

#import "gmd.h"
#import "GoWindow.h"
#import "GoMenu.h"

#include "_cgo_export.h"

GoMenu* gomenu;
NSBundle* fw;

int initMacDraw( void *mdata, int mlen, void *wdata, int wlen ) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSThread* nop = [NSThread alloc];
    
    ProcessSerialNumber psn;
    psn.highLongOfPSN = 0;
    psn.lowLongOfPSN = kCurrentProcess;
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);

    [NSApplication sharedApplication];

    // kickoff a thread that does nothing, so cocoa inits multi-threaded mode
    [[nop init] start];

    gomenu = [GoMenu alloc];

    [gomenu retain];
    
    [pool release];
    
    return GMDNoError;
}

void releaseMacDraw() {
    [fw release];
}

void NSAppRun() {
    [NSApp run];
}

void NSAppStop() {
    [NSApp terminate:nil];
}

void setAppName(char* name) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [gomenu setAppName:[NSString stringWithCString:name encoding:NSASCIIStringEncoding]];
    [pool release];
}

GMDWindow openWindow() {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    GoWindow* gw = [GoWindow alloc];
    if (gw == nil) {
        return nil;
    }
    int style = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
    id window = [[[EventWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200) styleMask:style backing:NSBackingStoreBuffered defer:NO] autorelease];
    [window makeKeyAndOrderFront:nil];
    [window setWindowController:gw];
    [gw setWindow:window];
    NSImageView* view = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)];
    [view setImageFrameStyle:NSImageFrameNone];
    [view setImageScaling:NSScaleNone];
    [view setImage:nil];
    [[window contentView] addSubview:view];
    [gw setImageView:view];
    [[gw window] orderFront:nil];
    [[gw eventWindow] setGw:gw];

    [NSApp activateIgnoringOtherApps:YES];
    
    [pool release];
    
    return (GMDWindow)gw;
}

int closeWindow(GMDWindow gmdw) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GoWindow* gw = (GoWindow*)gmdw;
    [gw close];
    [pool release];
    return 0;
}

void showWindow(GMDWindow gmdw) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GoWindow* gw = (GoWindow*)gmdw;
    [gw showWindow:nil];
    [[gw window] orderFront:nil];
    [pool release];
}

void hideWindow(GMDWindow gmdw) {
    
}

void setWindowTitle(GMDWindow gmdw, char* title) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GoWindow* gw = (GoWindow*)gmdw;
    NSString* nstitle = [NSString stringWithCString:title encoding:NSASCIIStringEncoding];
    [gw setTitle:nstitle];
    [pool release];
}

void setWindowSize(GMDWindow gmdw, int width, int height) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GoWindow* gw = (GoWindow*)gmdw;
    [gw setSize:CGSizeMake(width, height)];
    [pool release];    
}

void getWindowSize(GMDWindow gmdw, int* width, int* height) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GoWindow* gw = (GoWindow*)gmdw;
    CGSize size = [gw size];
    *width = size.width;
    *height = size.height;
    [pool release];
}

GMDEvent getNextEvent(GMDWindow gmdw) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GoWindow* gw = (GoWindow*)gmdw;
    EventWindow* ew = (EventWindow*)[gw window];
    GMDEvent e = [ew dq];
    [pool release];
    return e;
}

GMDImage getWindowScreen(GMDWindow gmdw) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GoWindow* gw = (GoWindow*)gmdw;
    ImageBuffer* ib = [gw buffer];
    [pool release];
    return ib;
}

void flushWindowScreen(GMDWindow gmdw) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GoWindow* gw = (GoWindow*)gmdw;
    [gw flush];
    [pool release];
}

void setScreenData(GMDImage screen, void* data) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    ImageBuffer* ib = (ImageBuffer*)screen;
    [ib setData:(UInt8*)data];
    [pool release];
}

void getScreenSize(GMDImage screen, int* width, int* height) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    ImageBuffer* ib = (ImageBuffer*)screen;
    CGSize size = [ib size];
    *width = size.width;
    *height = size.height;
    [pool release];
}

void taskReady() {
	dispatch_async(dispatch_get_main_queue(), ^{ runTask(); });
}

int isMainThread() {
	return [NSThread isMainThread];
}
