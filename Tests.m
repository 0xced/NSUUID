//
//  Tests.m
//
//  Copyright (c) 2013 Cédric Luthi. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface NSUUIDTests : SenTestCase
@end

@implementation NSUUIDTests

+ (void) initialize
{
	if (self != [NSUUIDTests class])
		return;
	
	// Avoid "Tests did not finish" error
	// http://stackoverflow.com/questions/12308297/some-of-my-unit-tests-tests-are-not-finishing-in-xcode-4-4/13945200#13945200
	[NSThread sleepForTimeInterval:0.5];
}

- (void) testNSUUID
{
	STAssertNotNil(NSClassFromString(@"NSUUID"), @"The NSUUID class must be available from the Objective-C runtime.");
	STAssertNotNil([NSUUID class], @"The NSUUID class must be available with direct messaging.");
	STAssertTrue(NSClassFromString(@"NSUUID") == [NSUUID class], @"There must not be two different NSUUID classes");
}

- (void) testImplementationClass
{
	NSUUID *uuid = [NSUUID UUID];
#if TARGET_OS_IPHONE
	if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1)
#else
	if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber10_7_4)
#endif
	{
		STAssertEqualObjects([NSUUID class], [uuid class], nil);
	}
	else
	{
		STAssertEqualObjects(NSClassFromString(@"__NSConcreteUUID"), [uuid class], nil);
	}
}

- (void) testInit
{
	uuid_t uuid;
	[[NSUUID UUID] getUUIDBytes:uuid];
	STAssertFalse(uuid_is_null(uuid), @"A new UUID must not be the null UUID.");
	
	NSUUID *uuidA = [[[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"] autorelease];
	NSUUID *uuidB = [[[NSUUID alloc] initWithUUIDString:@"e621e1f8-c36c-495a-93fc-0c247a3e6e5f"] autorelease];
	NSUUID *uuidC = [[[NSUUID alloc] initWithUUIDBytes:(uuid_t){0xE6,0x21,0xE1,0xF8,0xC3,0x6C,0x49,0x5A,0x93,0xFC,0x0C,0x24,0x7A,0x3E,0x6E,0x5F}] autorelease];
	STAssertEqualObjects(uuidA, uuidB, @"String case must not matter.");
	STAssertEqualObjects(uuidB, uuidC, @"A UUID initialized with a string must be equal to the same UUID initialized with a uuid_t");
}

- (void) testInvalidUUID
{
	NSUUID *uuid = [[[NSUUID alloc] initWithUUIDString:@"Invalid UUID"] autorelease];
	STAssertNil(uuid, @"The initWithUUIDString: method must return nil for an invalid UUID string.");
}

- (void) testUUIDString
{
	NSUUID *uuid = [[[NSUUID alloc] initWithUUIDBytes:(uuid_t){0xE6,0x21,0xE1,0xF8,0xC3,0x6C,0x49,0x5A,0x93,0xFC,0x0C,0x24,0x7A,0x3E,0x6E,0x5F}] autorelease];
	STAssertEqualObjects(@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F", [uuid UUIDString], @"The UUIDString must be formatted according to the UUID specification.");
}

- (void) testEquality
{
	NSUUID *uuidA = [NSUUID UUID];
	NSUUID *uuidB = [NSUUID UUID];
	
	STAssertTrue([uuidA isEqual:uuidA], @"The UUID must be equal to itself.");
	STAssertEqualObjects(uuidA, [[uuidA copy] autorelease], @"A copy of a UUID must be equal to the original UUID.");
	STAssertEquals([uuidA hash], [[[uuidA copy] autorelease] hash], @"Hashes of two identical UUIDs must be equal.");
	STAssertFalse([uuidA isEqual:uuidB], @"Two different UUIDs must not be equal.");
	STAssertFalse([uuidA isEqual:[NSDate date]], @"A UUIDs must not be equal to an object which is not a NSUUID.");
	STAssertFalse([uuidA isEqual:nil], @"A UUIDs must not be equal to nil.");
}

- (void) testNSCoding
{
#if !TARGET_OS_IPHONE
	STAssertThrows([NSArchiver archivedDataWithRootObject:[NSUUID UUID]], @"NSUUID must not support non keyed archiving.");
#endif
	
	NSUUID *uuidA = [NSUUID UUID];
	NSUUID *uuidB = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:uuidA]];
	STAssertEqualObjects(uuidA, uuidB, @"Archived then unarchived uuid must be equal.");
}

@end
