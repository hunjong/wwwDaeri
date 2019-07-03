//
//  NSData+AESAdditions.h
//  aes256
//
//  Created by EuiChan Hong on 2015. 3. 25..
//  Copyright (c) 2015년 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (AESAdditions)
- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;
@end