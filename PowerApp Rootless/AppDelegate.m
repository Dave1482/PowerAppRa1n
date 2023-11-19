//
//  AppDelegate.m
//  PowerApp
//
//  Modified by David Teddy, II on 11/18/2023.
//  Copyright © Since 2014 David Teddy, II (Dave1482). All rights reserved.
//

#import "AppDelegate.h"
#include <stdio.h>
#include <stdlib.h>
#include <spawn.h>
#include <dlfcn.h>

#define _POSIX_SPAWN_DISABLE_ASLR 0x0100
#define _POSIX_SPAWN_ALLOW_DATA_EXEC 0x2000
extern char **environ;

@interface AppDelegate ()

@end

@implementation AppDelegate

char *rebChar;
char *shutChar;
char *ldChar;

void run_action(char *cmd)
{
  rebChar = "kill 1";
  shutChar = "/var/jb/sbin/halt";
  if (cmd != rebChar && cmd != shutChar) {
    setgid(501);
    setuid(501);
  }
  pid_t pid;
  char *argv[] = {"sh", "-c", cmd, NULL};
  int status;
  status = posix_spawn(&pid, "/var/jb/bin/sh", NULL, NULL, (char* const*)argv, environ);
  
  if (status == 0) {
    printf("Child pid: %i\n", pid);
    if (waitpid(pid, &status, 0) != -1) {
      printf("Child exited with status %i\n", status);
    } else {
      perror("waitpid");
    }
  } else {
    printf("posix_spawn: %s\n", strerror(status));
  }
}

- (void)rebootActionPressed {
  long rebootControlValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"rebootControl"];
  switch (rebootControlValue) {
    case 0:
      setuid(0);
      setgid(0);
      run_action("kill 1");
      break;
    case 1:
      run_action("/var/jb/bin/launchctl reboot userspace");
      break;
    default:
      run_action("/var/jb/bin/launchctl reboot userspace");
    break;
  }
}

- (void)shutdownActionPressed {
  setuid(0);
  setgid(0);
  run_action("/var/jb/sbin/halt");
}

- (void)respringActionPressed {
  long btnControlValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"btnControl"];
  switch (btnControlValue) {
    case 0:
      run_action("/var/jb/usr/bin/killall -9 SpringBoard");
      break;
    case 1:
      run_action("/var/jb/usr/bin/killall -9 SpringBoard");
      break;
    default:
      run_action("/var/jb/usr/bin/killall -9 SpringBoard");
    break;
  }
}

- (void)safeModeActionPressed {
  run_action("/var/jb/usr/bin/killall -SEGV SpringBoard");
}

- (BOOL)handleShortCutItem:(UIApplicationShortcutItem *)shortcutItem {
  BOOL nahhh = NO;
  NSString *shortcutString = shortcutItem.type;
  if (shortcutItem == nil) {
    return nahhh;
  }
  if ([shortcutString isEqualToString:@"com.dave1482.powerapp.Reboot"]) {
    [self rebootActionPressed];
    nahhh = YES;
  }
  if ([shortcutString isEqualToString:@"com.dave1482.powerapp.Shutdown"]) {
    [self shutdownActionPressed];
    nahhh = YES;
  }
  if ([shortcutString isEqualToString:@"com.dave1482.powerapp.Respring"]) {
    [self respringActionPressed];
    nahhh = YES;
  }
  if ([shortcutString isEqualToString:@"com.dave1482.powerapp.SafeMode"]) {
    [self safeModeActionPressed];
    nahhh = YES;
  }
  return nahhh;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler API_AVAILABLE(ios(9)){
  [self handleShortCutItem:shortcutItem];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  @try {
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"systemTheme"];
  } @catch (NSException *exception) {
  } @finally {
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"systemTheme" options:NSKeyValueObservingOptionNew context:NULL];
  }
  if (@available (iOS 13,*)){
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"systemTheme"] != (int)UITraitCollection.currentTraitCollection.userInterfaceStyle) {
      if ([[NSUserDefaults standardUserDefaults] integerForKey:@"lightControl"] == 2) {
        [[NSUserDefaults standardUserDefaults] setInteger:(int)UITraitCollection.currentTraitCollection.userInterfaceStyle forKey:@"systemTheme"];
      }
    }
  }
}

- (void)dealloc {
  [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"systemTheme"];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end