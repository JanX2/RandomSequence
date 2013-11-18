//
//  RandomSequence.m
//
//  Version 1.0.1
//
//  Created by Nick Lockwood on 25/02/2012.
//  Copyright (c) 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/RandomSequence
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "RandomSequence.h"


static NSString *const SeedPropertyKey = @"seed";

static const uint32_t RandomMultiplier = 9301;
static const uint32_t RandomIncrement = 49297;
static const uint32_t RandomModulus = 233280;

#define RS_UNSIGNED     0
#define RS_SIGNED       1

@implementation RandomSequence

+ (RandomSequence *)defaultSequence
{
    static RandomSequence *defaultSequence = nil;
    if (defaultSequence == nil)
    {
        defaultSequence = [[self alloc] init];
    }
    return defaultSequence;
}

+ (instancetype)sequenceWithSeed:(uint32_t)seed
{
    RandomSequence *sequence = [[self alloc] init];
    sequence.seed = seed;
    return sequence;
}

- (RandomSequence *)init
{
    if ((self = [super init]))
    {
        _seed = arc4random() % RandomModulus;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _seed = [aDecoder decodeInt32ForKey:SeedPropertyKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:_seed forKey:SeedPropertyKey];
}

- (id)copyWithZone:(NSZone *)zone
{
    RandomSequence *sequence = [[[self class] allocWithZone:zone] init];
    sequence.seed = _seed;
    return sequence;
}

- (void)setSeed:(uint32_t)seed
{
    _seed = seed % RandomModulus;
}

NS_INLINE double valueForSeed(uint32_t seed) {
    return (double)seed / (double)RandomModulus;
}

- (double)value
{
    return valueForSeed(_seed);
}

NS_INLINE void updateSeed(uint32_t *seed_p) {
    *seed_p = (*seed_p * RandomMultiplier + RandomIncrement) % RandomModulus;
}

NS_INLINE double nextValueUpdatingSeed(uint32_t *seed_p) {
    updateSeed(&(*seed_p));
    return valueForSeed(*seed_p);
}

- (double)nextValue
{
    return nextValueUpdatingSeed(&_seed);
}

NS_INLINE NSUInteger nextIntegerInRangeUpdatingSeed(NSRange range, uint32_t *seed_p) {
    return floor(nextValueUpdatingSeed(seed_p) * (double)range.length) + range.location;
}

- (NSUInteger)nextIntegerInRange:(NSRange)range
{
    return nextIntegerInRangeUpdatingSeed(range, &_seed);
}

- (void)enumerateNumberOfIntegers:(NSUInteger)count
                          inRange:(NSRange)range
                       usingBlock:(void (^)(NSUInteger idx, NSUInteger serial, BOOL *stop))block
{
    [self enumerateNumberOfIntegers:count
                            inRange:range
                            options:0
                         usingBlock:block];
}

- (void)enumerateNumberOfSamples:(NSUInteger)count
                         inRange:(NSRange)range
                      usingBlock:(void (^)(NSUInteger idx, NSUInteger serial, BOOL *stop))block
{
    [self enumerateNumberOfIntegers:count
                            inRange:range
                            options:RSEnumerationSamples
                         usingBlock:block];
}

- (void)enumerateNumberOfIntegers:(NSUInteger)count
                          inRange:(NSRange)range
                          options:(RSEnumerationOptions)options
                       usingBlock:(void (^)(NSUInteger idx, NSUInteger serial, BOOL *stop))block
{
#   define INT_TYPE    RS_UNSIGNED
    
#   include "RandomSequenceEnumeration.m"

#   undef INT_TYPE
}


NS_INLINE NSInteger nextIntegerFromToUpdatingSeed(NSInteger from, NSInteger to, uint32_t *seed_p)
{
    return floor(nextValueUpdatingSeed(seed_p) * (double)(to - from)) + from;
}

- (NSInteger)nextIntegerFrom:(NSInteger)from to:(NSInteger)to
{
    return nextIntegerFromToUpdatingSeed(from, to, &_seed);
}

- (void)enumerateNumberOfIntegers:(NSInteger)count
                             from:(NSInteger)from
                               to:(NSInteger)to
                       usingBlock:(void (^)(NSInteger idx, NSInteger serial, BOOL *stop))block
{
    [self enumerateNumberOfIntegers:count
                               from:from
                                 to:to
                            options:0
                         usingBlock:block];
}

- (void)enumerateNumberOfSamples:(NSInteger)count
                            from:(NSInteger)from
                              to:(NSInteger)to
                      usingBlock:(void (^)(NSInteger idx, NSInteger serial, BOOL *stop))block
{
    [self enumerateNumberOfIntegers:count
                               from:from
                                 to:to
                            options:RSEnumerationSamples
                         usingBlock:block];
}

- (void)enumerateNumberOfIntegers:(NSInteger)count
                             from:(NSInteger)from
                               to:(NSInteger)to
                          options:(RSEnumerationOptions)options
                       usingBlock:(void (^)(NSInteger idx, NSInteger serial, BOOL *stop))block
{
#   define INT_TYPE    RS_SIGNED
    
#   include "RandomSequenceEnumeration.m"
    
#   undef INT_TYPE
}

@end


@implementation NSArray (RandomSequence)

- (NSUInteger)randomIndexWithSequence:(RandomSequence *)sequence
{
    return [self count]? [sequence nextIntegerInRange:NSMakeRange(0, [self count])]: NSNotFound;
}

- (id)randomObjectWithSequence:(RandomSequence *)sequence
{
    NSUInteger index = [self randomIndexWithSequence:sequence];
    return [self count]? self[index]: nil;
}

- (NSArray *)shuffledArrayWithSequence:(RandomSequence *)sequence
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array shuffleWithSequence:sequence];
    return array;
}

@end


@implementation NSMutableArray (RandomSequence)

- (void)shuffleWithSequence:(RandomSequence *)sequence
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; i++)
    {
        NSInteger index = [sequence nextIntegerInRange:NSMakeRange(i, count - i)];
        [self exchangeObjectAtIndex:i withObjectAtIndex:index];
    }
}

@end