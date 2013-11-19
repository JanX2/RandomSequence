//
//  RandomSequenceEnumeration.m
//  UnitTests
//
//  Created by Jan on 18.11.13.
//
//

// WARNING: If you want to debug this, you will have to copy the code, replacing the #include in the other file. LLDB can’t deal with metaprogramming doen this way. GDB could…
// NOTE: You don’t need to add this file to your target, as it is included directly and not linked as an object file referenced by a header file.

#ifdef INT_TYPE

#if (INT_TYPE == RS_UNSIGNED)

#   define nextIntegerUsingTypeUpdatingSeed(A, B, C)    nextIntegerInRangeUpdatingSeed((NSRange){(A), ((B) - (A))}, (C))

typedef NSUInteger IntType;

IntType rangeStart = range.location;
IntType rangeEnd = range.length;

#elif (INT_TYPE == RS_SIGNED)

#   define nextIntegerUsingTypeUpdatingSeed(A, B, C)    nextIntegerFromToUpdatingSeed((A), (B), (C))

typedef NSInteger IntType;

IntType rangeStart = from;
IntType rangeEnd = to;

#endif

__block BOOL stop = NO;

IntType rangeLength = (rangeEnd - rangeStart);

BOOL countCoversRangeLength = (count >= rangeLength);

IntType regionStart;
IntType regionEnd;
double region_length;

if (options & RSEnumerationSamples) {
    region_length = (double)rangeLength / (double)count;
    regionStart = rangeStart;
    //regionEnd = NSNotFound;
}

if (countCoversRangeLength) {
    count = rangeLength;
}

for (IntType i = 0; i < count; i++) {
    IntType idx;
    
    if (options & RSEnumerationSamples) {
        if (countCoversRangeLength) {
            // The `count` covers every integer in `range`.
            idx = rangeStart + i;
        }
        else {
            regionEnd = (region_length * (i + 1)) + 0.5; // Rounding to nearest integer.
            
            idx = nextIntegerUsingTypeUpdatingSeed(regionStart, regionEnd, &_seed);
            
            regionStart = regionEnd;
        }
    }
    else {
        idx = nextIntegerUsingTypeUpdatingSeed(rangeStart, rangeEnd, &_seed);
    }
    
    block(idx, i, &stop);
    
    if (stop) {
        break;
    }
}

#undef nextIntegerUsingTypeUpdatingSeed

#endif
