//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 Charcoal Design. All rights reserved.
//

#import "RandomSequenceTests.h"
#import "RandomSequence.h"


@implementation RandomSequenceTests

- (void)testRepeatability
{
    RandomSequence *sequence1 = [[RandomSequence alloc] init];
    RandomSequence *sequence2 = [RandomSequence sequenceWithSeed:sequence1.seed];
    
    NSArray *values = @[@"foo", @"bar", @"baz"];
    NSArray *shuffled1 = [values shuffledArrayWithSequence:sequence1];
    NSArray *shuffled2 = [values shuffledArrayWithSequence:sequence2];
    
    NSAssert([shuffled1 isEqualToArray:shuffled2], @"Repeatability test failed");
}

- (void)testUniqueness
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
    NSArray *values = @[@"foo", @"bar", @"baz"];
    NSArray *shuffled1 = [values shuffledArrayWithSequence:sequence];
    NSArray *shuffled2 = [values shuffledArrayWithSequence:sequence];
    
    NSAssert(![shuffled1 isEqualToArray:shuffled2], @"Uniqueness test failed");
}

- (void)testConsistency
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
    NSArray *values = @[@([sequence nextIntegerFrom:0 to:INT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:INT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:INT32_MAX]),
                        @([sequence nextIntegerFrom:0 to:INT32_MAX])];
    
    NSArray *compare = @[@(1007028800),
                         @(1652498240),
                         @(799479219),
                         @(1821642035)];
    
    NSAssert([values isEqualToArray:compare], @"Consistency test failed");
}

- (void)testEdgeCases
{
    uint32_t randomModulus = [RandomSequence randomModulus];
    double value;
    
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:0];
    value = sequence.value;
    NSAssert(value == 0.0, @"Edge Case test #1 failed");

    sequence.seed = randomModulus;
    value = sequence.value;
    NSAssert(value == 0.0, @"Edge Case test #2 failed");
    
    sequence.seed = randomModulus-1;
    value = sequence.value;
    NSAssert(value < 1.0, @"Edge Case test #3 failed");
}

- (void)testEnumeration
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
    NSArray *compare = @[@(1007028800),
                         @(1652498240),
                         @(799479219),
                         @(1821642035)];
    
    NSUInteger count = compare.count;
    
    [sequence enumerateNumberOfIntegers:count
                                inRange:NSMakeRange(0, INT32_MAX)
                             usingBlock:^(NSUInteger idx, NSUInteger serial, BOOL *stop) {
                                 #pragma unused (stop)
                                 //fprintf(stdout, "%f\t%lu\n", (double)serial/(double)count, (unsigned long)idx);
                                 NSAssert([compare[serial] isEqualToNumber:@(idx)], @"Enumeration test failed");
                             }];
    
    sequence.seed = 123456;
    
    [sequence enumerateNumberOfIntegers:count
                                   from:0
                                     to:INT32_MAX
                             usingBlock:^(NSInteger idx, NSInteger serial, BOOL *stop) {
                                 #pragma unused (stop)
                                 //fprintf(stdout, "%f\t%ld\n", (double)serial/(double)count, (long)idx);
                                 NSAssert([compare[serial] isEqualToNumber:@(idx)], @"Enumeration test failed");
                             }];
    
}

#if __LP64__
- (void)testEnumeration64Bit
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123457];
    
    NSArray *compare = @[@(9385793214527098880UL),
                         @(11167918862628917248UL),
                         @(3095649592753693184UL),
                         @(1167550481174217728UL)];
    
    NSUInteger count = compare.count;
    
    [sequence enumerateNumberOfIntegers:count
                                inRange:NSMakeRange(0, NSUIntegerMax)
                             usingBlock:^(NSUInteger idx, NSUInteger serial, BOOL *stop) {
                                 #pragma unused (stop)
                                 //fprintf(stdout, "%f\t%lu\n", (double)serial/(double)count, (unsigned long)idx);
                                 NSAssert([compare[serial] isEqualToNumber:@(idx)], @"Enumeration 64-bit test failed");
                             }];
}
#endif

- (void)testEnumerationSigned
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
    NSArray *compare = @[@(1007028800L),
                         @(1652498240L),
                         @(799479219L),
                         @(1821642035L)];
    
    NSUInteger count = compare.count;
    
    [sequence enumerateNumberOfIntegers:count
                                   from:0
                                     to:INT32_MAX
                             usingBlock:^(NSInteger idx, NSInteger serial, BOOL *stop) {
                                 #pragma unused (stop)
                                 //fprintf(stdout, "%f\t%ld\n", (double)serial/(double)count, (long)idx);
                                 NSAssert([compare[serial] isEqualToNumber:@(idx)], @"Enumeration Signed test failed");
                             }];
}

- (void)testEnumerationSampling
{
    RandomSequence *sequence = [RandomSequence sequenceWithSeed:123456];
    
#define RS_DUMP_MODE 0 // 0 == test (dumping disabled), 1 == stdout, 2 == file
    
#if RS_DUMP_MODE == 2
    FILE *file = fopen("samples.dump", "w");
#elif RS_DUMP_MODE == 1
    FILE *file = stdout;
#endif

#if RS_DUMP_MODE == 0
    NSArray *compare = @[@(1875UL),
                         @(7078UL),
                         @(9489UL),
                         @(15393UL)];
#endif
    
    NSUInteger sampleCount = 4;
    NSRange numberRange = NSMakeRange(0, 16000);
    
    [sequence enumerateNumberOfSamples:sampleCount
                               inRange:numberRange
                            usingBlock:^(NSUInteger idx, NSUInteger serial, BOOL *stop) {
                                #pragma unused (stop)
#if RS_DUMP_MODE > 0
                                fprintf(file, "%f\t%lu\n", (double)serial/(double)sampleCount, (unsigned long)idx);
#else
                                NSAssert([compare[serial] isEqualToNumber:@(idx)], @"Enumeration Sampling test failed");
#endif
                            }];
    
#if RS_DUMP_MODE == 2
    fclose(file);
#endif
}

@end
