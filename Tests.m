//
//  Tests.m
//
//  Copyright (c) 2013-2014 Cédric Luthi. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSUUIDTests : XCTestCase
@end

@implementation NSUUIDTests

- (void) testNSUUID
{
	XCTAssertNotNil(NSClassFromString(@"NSUUID"), @"The NSUUID class must be available from the Objective-C runtime.");
	XCTAssertNotNil([NSUUID class], @"The NSUUID class must be available with direct messaging.");
	XCTAssertTrue(NSClassFromString(@"NSUUID") == [NSUUID class], @"There must not be two different NSUUID classes");
}

- (void) testImplementationClass
{
	NSUUID *uuid = [NSUUID UUID];
	XCTAssertTrue([uuid isKindOfClass:[NSUUID class]], @"");
#if TARGET_OS_IPHONE
	if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1)
#else
	if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber10_7_4)
#endif
	{
		XCTAssertEqualObjects([NSUUID class], [uuid class], @"Concrete class must be NSUUID");
	}
	else
	{
		XCTAssertEqualObjects(NSClassFromString(@"__NSConcreteUUID"), [uuid class], @"Concrete class must be __NSConcreteUUID");
	}
}

- (void) testInit
{
	uuid_t uuid;
	[[NSUUID UUID] getUUIDBytes:uuid];
	XCTAssertFalse(uuid_is_null(uuid), @"A new UUID must not be the null UUID.");
	
	NSUUID *uuidA = [[[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"] autorelease];
	NSUUID *uuidB = [[[NSUUID alloc] initWithUUIDString:@"e621e1f8-c36c-495a-93fc-0c247a3e6e5f"] autorelease];
	NSUUID *uuidC = [[[NSUUID alloc] initWithUUIDBytes:(uuid_t){0xE6,0x21,0xE1,0xF8,0xC3,0x6C,0x49,0x5A,0x93,0xFC,0x0C,0x24,0x7A,0x3E,0x6E,0x5F}] autorelease];
	XCTAssertEqualObjects(uuidA, uuidB, @"String case must not matter.");
	XCTAssertEqualObjects(uuidB, uuidC, @"A UUID initialized with a string must be equal to the same UUID initialized with a uuid_t");
}

- (void) testInvalidUUID
{
	NSUUID *uuid = [[[NSUUID alloc] initWithUUIDString:@"Invalid UUID"] autorelease];
	XCTAssertNil(uuid, @"The initWithUUIDString: method must return nil for an invalid UUID string.");
}

- (void) testUUIDString
{
	NSUUID *uuid = [[[NSUUID alloc] initWithUUIDBytes:(uuid_t){0xE6,0x21,0xE1,0xF8,0xC3,0x6C,0x49,0x5A,0x93,0xFC,0x0C,0x24,0x7A,0x3E,0x6E,0x5F}] autorelease];
	XCTAssertEqualObjects(@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F", [uuid UUIDString], @"The UUIDString must be formatted according to the UUID specification.");
}

- (void) testDescription
{
	NSUUID *uuid = [[[NSUUID alloc] initWithUUIDBytes:(uuid_t){0xE6,0x21,0xE1,0xF8,0xC3,0x6C,0x49,0x5A,0x93,0xFC,0x0C,0x24,0x7A,0x3E,0x6E,0x5F}] autorelease];
	XCTAssertTrue([[uuid description] rangeOfString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"].location != NSNotFound, @"The UUID description must contain the UUID string.");
}

- (void) testEquality
{
	NSUUID *uuidA = [NSUUID UUID];
	NSUUID *uuidB = [NSUUID UUID];
	
	XCTAssertTrue([uuidA isEqual:uuidA], @"The UUID must be equal to itself.");
	XCTAssertEqualObjects(uuidA, [[uuidA copy] autorelease], @"A copy of a UUID must be equal to the original UUID.");
	XCTAssertEqual([uuidA hash], [[[uuidA copy] autorelease] hash], @"Hashes of two identical UUIDs must be equal.");
	XCTAssertFalse([uuidA isEqual:uuidB], @"Two different UUIDs must not be equal.");
	XCTAssertFalse([uuidA isEqual:[NSDate date]], @"A UUIDs must not be equal to an object which is not a NSUUID.");
	XCTAssertFalse([uuidA isEqual:nil], @"A UUIDs must not be equal to nil.");
}

- (void) testNSCoding
{
#if !TARGET_OS_IPHONE
	XCTAssertThrows([NSArchiver archivedDataWithRootObject:[NSUUID UUID]], @"NSUUID must not support non keyed archiving.");
#endif
	
	NSUUID *uuidA = [NSUUID UUID];
	NSUUID *uuidB = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:uuidA]];
	XCTAssertEqualObjects(uuidA, uuidB, @"Archived then unarchived uuid must be equal.");
}

- (void) testSecureCoding
{
	XCTAssertTrue([NSUUID supportsSecureCoding], @"The NSUUID class must support secure coding.");
}

@end
