//
//  NSUUID.m
//
//  Copyright (c) 2013 Cédric Luthi. All rights reserved.
//

#import <Availability.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
#error Do not compile this file if you are targeting iOS 6.0 or later
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_8
#error Do not compile this file if you are targeting OS X 10.8 or later
#endif

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <uuid/uuid.h>

#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
#pragma clang diagnostic ignored "-Wundef"

@interface XCDUUID : NSObject <NSCopying, NSSecureCoding>
{
	uuid_t _uuid;
}
+ (id)UUID;
- (id)init;
- (id)initWithUUIDBytes:(const uuid_t)bytes;
- (id)initWithUUIDString:(NSString *)string;
- (void)getUUIDBytes:(uuid_t)uuid;
- (NSString *)UUIDString;
@end

@implementation XCDUUID

+ (id) UUID
{
	return [[[self alloc] init] autorelease];
}

- (id) init
{
	if ((self = [super init]))
	{
		uuid_generate_random(_uuid);
	}
	return self;
}

- (id) initWithUUIDBytes:(const uuid_t)bytes
{
	if ((self = [super init]))
	{
		// crashes if bytes == NULL (same as Apple implementation)
		uuid_copy(_uuid, bytes);
	}
	return self;
}

- (id) initWithUUIDString:(NSString *)string
{
	if ((self = [super init]))
	{
		if (uuid_parse([string UTF8String], _uuid) != 0)
		{
			[self release];
			self = nil;
		}
	}
	return self;
}

- (void) getUUIDBytes:(uuid_t)uuid
{
	uuid_copy(uuid, _uuid);
}

- (NSString *) UUIDString
{
	uuid_string_t string;
	uuid_unparse_upper(_uuid, string);
	return [NSString stringWithUTF8String:string];
}

#pragma mark - NSObject

- (BOOL) isEqual:(id)object
{
	if (self == object)
	{
		return YES;
	}
	else if ([object isKindOfClass:[self class]])
	{
		uuid_t uuid;
		[object getUUIDBytes:uuid];
		return uuid_compare(_uuid, uuid) == 0;
	}
	else
	{
		return NO;
	}
}

- (NSUInteger) hash
{
	NSData *data = [[NSData alloc] initWithBytes:_uuid length:sizeof(_uuid)];
	NSUInteger hash = [data hash];
	[data release];
	return hash;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"<%@ %p> %@", [self class], self, [self UUIDString]];
}

#pragma mark - NSCopying

- (id) copyWithZone:(NSZone *)zone
{
	return [self retain];
}

#pragma mark - NSSecureCoding

+ (BOOL) supportsSecureCoding
{
	return YES;
}

#pragma mark - NSCoding

- (id) initWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		NSUInteger length = 0;
		const uint8_t *uuid = [coder decodeBytesForKey:@"NS.uuidbytes" returnedLength:&length];
		if (length == sizeof(uuid_t))
		{
			return [self initWithUUIDBytes:uuid];
		}
		else
		{
			return [self init];
		}
	}
	else
	{
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-[NSUUID initWithCoder]: NSUUIDs cannot be decoded by non-keyed coders" userInfo:nil];
	}
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[coder encodeBytes:_uuid length:sizeof(_uuid) forKey:@"NS.uuidbytes"];
	}
	else
	{
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-[NSUUID encodeWithCoder]: NSUUIDs cannot be encoded by non-keyed coders" userInfo:nil];
	}
}

+ (void) load
{
	if (objc_getClass("NSUUID"))
	{
		return;
	}
	
	Class *NSUUIDClassRef = NULL;
#if TARGET_CPU_ARM
	__asm(
	      "movw %0, :lower16:(L_OBJC_CLASS_NSUUID-(LPC0+4))\n"
	      "movt %0, :upper16:(L_OBJC_CLASS_NSUUID-(LPC0+4))\n"
	      "LPC0: add %0, pc" : "=r"(NSUUIDClassRef)
	);
#elif TARGET_CPU_ARM64
	__asm(
	      "adrp %0, L_OBJC_CLASS_NSUUID@PAGE\n"
	      "add  %0, %0, L_OBJC_CLASS_NSUUID@PAGEOFF" : "=r"(NSUUIDClassRef)
	);
#elif TARGET_CPU_X86_64
	__asm("leaq L_OBJC_CLASS_NSUUID(%%rip), %0" : "=r"(NSUUIDClassRef));
#elif TARGET_CPU_X86
	void *pc = NULL;
	__asm(
	      "calll L0\n"
	      "L0: popl %0\n"
	      "leal L_OBJC_CLASS_NSUUID-L0(%0), %1" : "=r"(pc), "=r"(NSUUIDClassRef)
	);
#else
#error Unsupported CPU
#endif
	if (NSUUIDClassRef && *NSUUIDClassRef == Nil)
	{
		Class NSUUIDClass = objc_allocateClassPair(self, "NSUUID", 0);
		if (NSUUIDClass)
		{
			objc_registerClassPair(NSUUIDClass);
			*NSUUIDClassRef = NSUUIDClass;
		}
	}
}

__asm(
#if defined(__OBJC2__) && __OBJC2__
	".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
	#if	TARGET_RT_64_BIT
		".align          3\n"
		"L_OBJC_CLASS_NSUUID:\n"
		".quad           _OBJC_CLASS_$_NSUUID\n"
	#else
		".align          2\n"
		"L_OBJC_CLASS_NSUUID:\n"
		".long           _OBJC_CLASS_$_NSUUID\n"
	#endif
#else
	".section        __TEXT,__cstring,cstring_literals\n"
	"L_OBJC_CLASS_NAME_NSUUID:\n"
	".asciz          \"NSUUID\"\n"
	".section        __OBJC,__cls_refs,literal_pointers,no_dead_strip\n"
	".align          2\n"
	"L_OBJC_CLASS_NSUUID:\n"
	".long           L_OBJC_CLASS_NAME_NSUUID\n"
#endif
".weak_reference _OBJC_CLASS_$_NSUUID\n"
);

@end
