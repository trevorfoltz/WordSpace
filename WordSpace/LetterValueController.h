//
//  LetterValueController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LetterValue.h"

@protocol LetterValueControllerDelegate;

@interface LetterValueController : NSObject <NSXMLParserDelegate>
{
    
}

@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, assign) id <LetterValueControllerDelegate> delegate;
@property (nonatomic, retain) NSXMLParser *letterValueParser;
@property (nonatomic, retain) NSString *currentKey;
@property (nonatomic, retain) NSMutableString *letterStr, *pointValueStr, *letterCountStr;

@property (nonatomic, retain) NSMutableData *letterValueData;
@property (nonatomic, retain) NSMutableDictionary *letterValues;

- (void)getLetterValues;
- (void)parseLetterValueData:(NSMutableData *) theLetterValueData;
@end

@protocol LetterValueControllerDelegate
- (void)letterValuesReturned:(NSMutableDictionary *) ltrValues;
@end
