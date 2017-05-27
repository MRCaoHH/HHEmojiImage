//
//  ViewController.m
//  HHEmojiImage
//
//  Created by caohuihui on 2017/5/27.
//  Copyright © 2017年 caohuihui. All rights reserved.
//

#import "ViewController.h"

static const NSString *kDirPath = @"/Users/caohuihui/Desktop/emoji";
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   dispatch_queue_t queue =  dispatch_queue_create("createImg", NULL);
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        [weakSelf createImg];
    });
    
}


- (void)createImg{
    NSString *emojiPath = [[NSBundle mainBundle]pathForResource:@"EmojisMap" ofType:@"plist"];
    NSDictionary *emojiDic = [NSDictionary dictionaryWithContentsOfFile:emojiPath];
    int i = 0;
    NSMutableArray *arr = [NSMutableArray new];
    for (NSString *emoji in emojiDic.allValues) {
        UIImage *img = [self imageFromText:emoji withFont:100];
        NSString *imgName = [NSString stringWithFormat:@"%i.png",i];
        [self saveImg:img imgName:imgName];
        NSString *log = [NSString stringWithFormat:@"生成图片:%@\n",imgName];
        [self performSelectorOnMainThread:@selector(writeLog:) withObject:log waitUntilDone:YES];
        NSDictionary *dic = @{@"code":emoji,@"imgName":imgName};
        [arr addObject:dic];
        i++;
    }
    
    NSString *imgPath = [kDirPath stringByAppendingPathComponent:@"emojiList.plist"];
    [arr writeToFile:imgPath atomically:YES];
    [self performSelectorOnMainThread:@selector(writeLog:) withObject:@"写入配置文件:emojiList.plist\n完毕" waitUntilDone:YES];
}

- (void)writeLog:(NSString *)log{
    _textView.text = [_textView.text stringByAppendingString:log];
    CGFloat offsetY = _textView.contentSize.height - _textView.frame.size.height;
    offsetY = offsetY > 0?offsetY:0;
    [_textView setContentOffset:CGPointMake(0, offsetY)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIImage *)imageFromText:(NSString*)string withFont: (CGFloat)fontSize

{
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    CGSize newSize = [string sizeWithAttributes:@{NSFontAttributeName:font}];
    
    UIGraphicsBeginImageContextWithOptions(newSize,NO,0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
//    CGContextSetCharacterSpacing(ctx, 10);
    
    CGContextSetTextDrawingMode (ctx, kCGTextFillStroke);
    
    CGContextSetRGBFillColor (ctx, 1, 1, 1, 0); // 6
    
    [string drawAtPoint:CGPointMake(0,0) withAttributes:@{NSFontAttributeName:font}];
    
    // transfer image
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    return image;
}

- (void)saveImg:(UIImage *)img imgName:(NSString *)imgName{
    NSString *imgPath = [kDirPath stringByAppendingPathComponent:imgName];
    NSData *data = UIImagePNGRepresentation(img);
    [data writeToFile:imgPath atomically:YES];
}

@end
