//
//  RandomSequence.h
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

#import <Foundation/Foundation.h>

enum {
    RSEnumerationSamples =         (1UL << 0),            /* If specified, distributes the integer sequence over the range and enumerates in ascending order. */
};
typedef NSUInteger RSEnumerationOptions;

@interface RandomSequence : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) uint32_t seed;

+ (instancetype)defaultSequence;
+ (instancetype)sequenceWithSeed:(uint32_t)seed;

- (double)value; // 0.0 <= value < 1.0. value can never reach 1.0!
- (double)nextValue;
- (NSUInteger)nextIntegerInRange:(NSRange)range; // returns an integer i with NSLocationInRange(i, range) == YES
- (NSInteger)nextIntegerFrom:(NSInteger)from to:(NSInteger)to; // returns an integer i with from <= i < to

- (void)enumerateNumberOfIntegers:(NSUInteger)count
                          inRange:(NSRange)range
                       usingBlock:(void (^)(NSUInteger idx, NSUInteger serial, BOOL *stop))block;

- (void)enumerateNumberOfSamples:(NSUInteger)count
                         inRange:(NSRange)range
                      usingBlock:(void (^)(NSUInteger idx, NSUInteger serial, BOOL *stop))block;

- (void)enumerateNumberOfIntegers:(NSUInteger)count
                          inRange:(NSRange)range
                          options:(RSEnumerationOptions)options
                       usingBlock:(void (^)(NSUInteger idx, NSUInteger serial, BOOL *stop))block;

- (void)enumerateNumberOfIntegers:(NSInteger)count
                             from:(NSInteger)from
                               to:(NSInteger)to
                       usingBlock:(void (^)(NSInteger idx, NSInteger serial, BOOL *stop))block;

- (void)enumerateNumberOfSamples:(NSInteger)count
                            from:(NSInteger)from
                              to:(NSInteger)to
                      usingBlock:(void (^)(NSInteger idx, NSInteger serial, BOOL *stop))block;

- (void)enumerateNumberOfIntegers:(NSInteger)count
                             from:(NSInteger)from
                               to:(NSInteger)to
                          options:(RSEnumerationOptions)options
                       usingBlock:(void (^)(NSInteger idx, NSInteger serial, BOOL *stop))block;

@end


@interface NSArray (RandomSequence)

- (NSUInteger)randomIndexWithSequence:(RandomSequence *)sequence;
- (id)randomObjectWithSequence:(RandomSequence *)sequence;
- (NSArray *)shuffledArrayWithSequence:(RandomSequence *)sequence;

@end


@interface NSMutableArray (RandomSequence)

- (void)shuffleWithSequence:(RandomSequence *)sequence;

@end