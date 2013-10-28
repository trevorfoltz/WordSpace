//
//  CheckWordController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CheckWordControllerDelegate;

@interface CheckWordController : NSObject <NSXMLParserDelegate>
{
    
}

@property (nonatomic, assign) id <CheckWordControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, retain) NSMutableData *wordData;
@property (nonatomic, retain) NSXMLParser *wordParser;

@property (nonatomic, retain) NSMutableString *currentWord;
@property (nonatomic, retain) NSMutableArray *badWords;
@property (nonatomic, retain) NSString *currentKey;

- (void)checkWords:(NSArray *) words;
- (void)parseWordData:(NSData *) theWordData;

@end

@protocol CheckWordControllerDelegate

- (void)checkedWordsReturned:(NSMutableArray *) words;

@end