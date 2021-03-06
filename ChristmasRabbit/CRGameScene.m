//
//  CRGameScene.m
//  ChristmasRabbit
//
//  Created by xiefei on 14/12/10.
//  Copyright (c) 2014年 xiefei. All rights reserved.
//

#import "CRGameScene.h"
#import <CoreMotion/CoreMotion.h>
#import "CRBellSpriteNode.h"
#import <objc/runtime.h>
#import "PPSpriteButton.h"
#import "MyScreenKit.h"
#import <AVFoundation/AVFoundation.h>

#define BELL_SIZE CGSizeMake(40.0f,40.f)
#define RABBIT_SIZE CGSizeMake(50.0f,50.f)
#define BELL_DIRECTION_VALUE 60.0f
#define BELL_IMPULSE_VALUE 80.0f
#define BELL_NODE_NAME @"bellnodename"
#define RABBIT_NODE_NAME @"rabbitnodename"
#define WALL_NODE_NAME @"bottomnodename"
#define STAR_NODE_NAME @"starsnodename"
#define HISTORY_SCORES_KEY @"historyscores"
#define kNumClouds			15

#define kMinBellsStep	75
#define kMaxBellsStep	300
#define kNumBells		15
#define kBellsTopPadding 30
#define kUserMaxScores @"kusermaxscores"

#define kMinBonusStep		30
#define kMaxBonusStep		50

@interface NSObject (ExtendedProperties)
@property (nonatomic, strong, readwrite) id PPBellPhysicsBodyStatus;
@property (nonatomic, strong, readwrite) id PPBellSkillStatus;
@end


static void * MyObjectMyCustomPorpertyKey = (void *) @"MyObjectMyCustomPorpertyKey";
static void * MyObjectMyCustomPorpertyKey1 = (void *) @"MyObjectMyCustomPorpertyKey1";

@implementation NSObject (ExtendedProperties)

- (id)PPBellPhysicsBodyStatus
{
    return objc_getAssociatedObject(self, MyObjectMyCustomPorpertyKey);
}

- (void)setPPBellPhysicsBodyStatus:(id)myCustomProperty
{
    objc_setAssociatedObject(self, MyObjectMyCustomPorpertyKey, myCustomProperty, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)PPBellSkillStatus
{
    return objc_getAssociatedObject(self, MyObjectMyCustomPorpertyKey1);
}

- (void)setPPBellSkillStatus:(id)myCustomProperty
{
    objc_setAssociatedObject(self, MyObjectMyCustomPorpertyKey1, myCustomProperty, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


typedef NS_ENUM(int, kBellType) {
    
    kBellTypeTypeNormal,
    kBellTypeTypeSpecial,
    
};

typedef NS_ENUM(int, kGameTagValues){
    kSpriteManager = 0,
    kBird,
    kScoreLabel,
    kCloudsStartTag = 100,
    kBellsStartTag = 200,
    kBonusStartTag = 300
};
// Implementation


@interface CRGameScene()<SKSceneDelegate,SKPhysicsContactDelegate>
{
    CGPoint rabbit_pos;
    SKSpriteNode *rabbitNode;
    int contactedIndex;
    int totalBallNums;
    UIView *stopView;
    BOOL isStart;
    CMMotionManager *motionManager;
    SKSpriteNode *contentBellNode;
    SKLabelNode *altitudeValueLebel;
    CGFloat totalScores;
}
@property(nonatomic,strong)AVAudioPlayer * bgmPlayer;
@end


@implementation CRGameScene

@synthesize bgmPlayer;
-(id)initWithSize:(CGSize)size
{
    self=[super initWithSize:size];
    
    if (self) {
        
        isStart = NO;
        totalBallNums = 0;
        contactedIndex = 0;
        
        
        //        contentBellNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:self.size];
        //        [contentBellNode setPosition:CGPointMake(self.size.width/2.0f, self.size.height/2.0f)];
        //        [self addChild:contentBellNode];
        
        
        //        [self runAction:[SKAction repeatActionForever:[SKAction sequence:[NSArray arrayWithObjects:[SKAction performSelector:@selector(initStar) onTarget:self],[SKAction waitForDuration:1], nil]]]];
        
        
        
        [self initBackGround];
        [self initBells];
        [self initBottomWall:CGPointMake(self.size.width/2.0f, 100.0f) andSize:CGSizeMake(self.size.width, 86.0f)];
        [self initAltitudeValueLebel];
        [self startMotionManager];
        [self initStar];
        
    }
    
    return self;
}

- (void)playSoundWithName:(NSString *)fileName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runAction:[SKAction playSoundFileNamed:fileName waitForCompletion:YES]];
    });
}
#define mark Init nodes
-(void)initBackGround
{
    SKSpriteNode *backNode =[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"gamesceneback"]];
    backNode.zPosition = -2;
    backNode.size = self.size;
    backNode.position = CGPointMake(self.size.width/2.0f, self.size.height/2.0f);
    [self addChild:backNode];
    
}
-(void)initStar
{
    
    for (int i =0; i<3; i++) {
        SKSpriteNode * starNode =nil;
        float starSize=16;
        starSize+=8-random()%16;
        if (arc4random()%2==0) {
            
            starNode =[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"star1"]];
        }else
        {
            starNode =[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"star2"]];

        }
        
        starNode.size= CGSizeMake(starSize, starSize);
        //    starNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:starSize];
        //    starNode.physicsBody.velocity =CGVectorMake(0.0f, random()%6);
        //    starNode.physicsBody.density = 0;
        
        starNode.position = CGPointMake(random()%312+4, self.size.height+random()%10);
        starNode.name = STAR_NODE_NAME;
        starNode.zPosition = -1;
        [self addChild:starNode];
        
        int durationValue=arc4random()%6+3;
        
        SKAction *actionStarRotate = [SKAction rotateByAngle:M_1_PI*20 duration:durationValue];
        SKAction *actionStar = [SKAction moveByX:arc4random()%5 y:-self.size.height+100 duration:durationValue];
        
        SKAction *actionStarResult = [SKAction group:[NSArray arrayWithObjects:actionStarRotate,actionStar, nil]];
        
        [starNode runAction:actionStarResult completion:^{
            [starNode removeFromParent];
        }];
        
        
    }
    
    [self performSelector:@selector(initStar) withObject:nil afterDelay:1.0];
    
}
-(void)initAltitudeValueLebel
{
    
    altitudeValueLebel = [[SKLabelNode alloc] init];
    [altitudeValueLebel setText:@"0m"];
    [altitudeValueLebel setFontColor:[UIColor yellowColor]];
    [altitudeValueLebel setFontSize:15];
    [altitudeValueLebel setPosition:CGPointMake(self.size.width/2.0f, self.size.height-20)];
    [self addChild:altitudeValueLebel];
    
    
}

-(void)initBottomWall:(CGPoint)position andSize:(CGSize)size
{
    
    SKNode *wallnodePrevious=[self childNodeWithName:WALL_NODE_NAME];
    if (wallnodePrevious) {
        wallnodePrevious.physicsBody = nil;
        [wallnodePrevious removeFromParent];
        wallnodePrevious = nil;
    }
    
    //    [self enumerateChildNodesWithName:WALL_NODE_NAME usingBlock:^(SKNode *node,BOOL *stop){
    //
    //        [node removeFromParent];
    //
    //    }];
    
    
//    SKSpriteNode *wallNode=[SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:size];
    
    SKSpriteNode *wallNode=[SKSpriteNode spriteNodeWithImageNamed:@"groundImage"];
    wallNode.position = position;
    wallNode.size = CGSizeMake(self.size.width, 145.0f);
    wallNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width, 20.0f) center:CGPointMake(0.0f, -40.0f)];
    wallNode.physicsBody.dynamic = NO;
    
    wallNode.name = WALL_NODE_NAME;
    wallNode.physicsBody.categoryBitMask=10;
    [self addChild:wallNode];
    
    
    
    
}

- (void)initBells
{
    //	NSLog(@"initBells");
    
    currentBellTag = kBellsStartTag;
    
    while(currentBellTag < kBellsStartTag + kNumBells) {
        [self initBellNode];
        currentBellTag++;
    }
    [self resetBells];
    
}

- (void)initBellNode {
    
    
    //	CGRect rect;
    //	switch(random()%2) {
    //		case 0: rect = CGRectMake(608,64,102,36); break;
    //		case 1: rect = CGRectMake(608,128,90,32); break;
    //	}
    //
    //	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
    
    //    NSString *imagName = [NSString stringWithFormat:@"Bell%ld.png",random()%5+1];
    //    UIImage *image = [UIImage imageNamed:imagName];
    //    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:imagName];
    //    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //    Bell *Bell = [Bell spriteWithSpriteFrame:frame];
    
    
    
    //    Bell *Bell = [Bell spriteWithSpriteFrameName:[NSString stringWithFormat:@"Bell%d.png",arc4random()%5+1]];
    //    [self addChild:Bell z:3 tag:currentBellTag];
    
    
    CRBellSpriteNode *sprite = [[CRBellSpriteNode alloc] initWithImageNamed:@"bell01"];
    sprite.size = BELL_SIZE;
//    sprite.xScale = 0.5;
//    sprite.yScale = 0.5;
    //    sprite.position = CGPointMake(xValue, yValue+100);
    sprite.name = [NSString stringWithFormat:@"%@%d",BELL_NODE_NAME,currentBellTag];
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10 center:CGPointMake(0.0f, 0.0)];
    sprite.physicsBody.affectedByGravity = NO;
    //    SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
    sprite.physicsBody.categoryBitMask =4;
    sprite.physicsBody.collisionBitMask = 3;
    sprite.physicsBody.contactTestBitMask = 1;
    sprite.physicsBody.density = 1;
    sprite.physicsBody.PPBellPhysicsBodyStatus =[NSNumber numberWithInt:currentBellTag];


    //    [sprite runAction:[SKAction repeatActionForever:action]];
    
    
    [self addChild:sprite];
    
 
    
    
}
-(void)initRemoveBellAnimationNode:(CGPoint)pointPos
{
    
    SKSpriteNode *nodeAni=[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"remvoveAnimation"]];
    nodeAni.position = pointPos;
    nodeAni.position = CGPointMake(rabbitNode.position.x, rabbitNode.position.y-20.0f);
    nodeAni.size = BELL_SIZE;
    [self addChild:nodeAni];
    SKAction *actionScale = [SKAction scaleTo:2 duration:1];
    SKAction *actionFade = [SKAction fadeAlphaTo:0.0 duration:1];
    [nodeAni runAction:[SKAction group:[NSArray arrayWithObjects:actionScale,actionFade, nil]]];
    
}
-(void)initRabbitNode
{
    
    
    if (rabbitNode) {
        [rabbitNode removeFromParent];
    }
    
    
    //    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsWorld.contactDelegate = self;
    rabbitNode=[SKSpriteNode spriteNodeWithImageNamed:@"rabbit01"];
    rabbitNode.size = RABBIT_SIZE;
    //    rabbitNode.xScale = 0.5;
    //    rabbitNode.yScale = 0.5;
    rabbitNode.position = CGPointMake(self.size.width/2.0f, 63.0f);
    rabbitNode.name = RABBIT_NODE_NAME;
    
    
    rabbitNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:RABBIT_SIZE];
    //    rabbitNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    rabbitNode.physicsBody.affectedByGravity = YES;
    rabbitNode.physicsBody.allowsRotation = NO;
    rabbitNode.physicsBody.categoryBitMask = 1;
    rabbitNode.physicsBody.collisionBitMask =2;
    rabbitNode.physicsBody.contactTestBitMask = 10;
    
    NSMutableArray *rabbitTextureArray=[[NSMutableArray alloc] initWithCapacity:3];
    
    
    for (int i=1; i<=3; i++) {
        SKTexture *textureRabbit=[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"rabbit%02d",i]];
        [rabbitTextureArray addObject:textureRabbit];
    }
    SKAction *action = [SKAction animateWithTextures:rabbitTextureArray timePerFrame:0.2];
    [rabbitNode runAction:[SKAction repeatActionForever:action]];
    [self addChild:rabbitNode];
    
    
}

#pragma mark reset methods

-(void)restartGame
{
    
    isStart = NO;
    contactedIndex = 0;
    totalScores = 0;
    totalBallNums = 0;
    [contentBellNode setPosition:CGPointMake(self.size.width/2.0f, self.size.height/2.0f)];
    self.paused = NO;
    [self resetBells];
    [self initBottomWall:CGPointMake(self.size.width/2.0f, 100.0f) andSize:CGSizeMake(self.size.width, 86.0f)];
    [self initRabbitNode];
    [self startMotionManager];
    
    
}
-(void)resetBells
{
    
    currentBellY = -1;
    currentBellTag = kBellsStartTag;
    currentMaxBellStep = 60.0f;
    currentBonusBellIndex = 0;
    currentBonusType = 0;
    BellCount = 0;
    
    while(currentBellTag < kBellsStartTag + kNumBells) {
        [self resetEveryBell];
        currentBellTag++;
    }
    
    
}

-(void)resetRemovedBell:(int)index
{
    
    //    CRBellSpriteNode *bellNode = (CRBellSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"%d",index]];
    //    bellNode.position = CGPointMake(bellNode, <#CGFloat y#>)
    
}

-(void)resetEveryBell
{
    
    
    if(currentBellY < 0) {
        
        currentBellY = kMinBellsStep+100;
        
    } else {
        
        //        currentBellY += random() % (int)(currentMaxBellStep - kMinBellsStep) + kMinBellsStep;
        currentBellY += kMinBellsStep;
        
        //        if(currentMaxBellStep < kMaxBellsStep) {
        //            currentMaxBellStep += 0.5f;
        //        }
        //
        
    }
    
    //CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
    CRBellSpriteNode *bellNode = (CRBellSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"%@%d",BELL_NODE_NAME,currentBellTag]];
    
    //    if (!bellNode.physicsBody.dynamic) {
    //        bellNode.physicsBody.dynamic = NO;
    //    }
    
    
    if (bellNode) {
        
        if (bellNode != nil) {
            [bellNode  removeAllActions];
        }
        
        //    if(random()%2==1) bellNode.xScale = 1.0f;
        
        
        if (random()%13==1) {
            bellNode.type = kBellTypeTypeSpecial;
            //换成特殊铃铛
        }
        else{
            bellNode.type = kBellTypeTypeNormal;
            
            //设置普通铃铛
        }
        
        
        
        
        
        float x;
        CGSize size = bellNode.size;
        if(currentBellY == kMinBellsStep) {
            x = self.size.width/2.0f;
        } else {
            x = random()%((int)self.size.width-(int)size.width) + size.width/2;
        }
        
        NSLog(@"currentBellY=%f",currentBellY);
        
        
        bellNode.position = CGPointMake(x,currentBellY);
        bellNode.hidden = NO;
        
        if (bellNode.physicsBody) {
            
            bellNode.physicsBody.dynamic = NO;
            
        }else
        {
            
            bellNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10 center:CGPointMake(0.0f, 0.0)];
            bellNode.physicsBody.affectedByGravity = NO;
            //    SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
            bellNode.physicsBody.categoryBitMask =4;
            bellNode.physicsBody.collisionBitMask = 3;
            bellNode.physicsBody.contactTestBitMask = 1;
            bellNode.physicsBody.density = 1;
            bellNode.physicsBody.PPBellPhysicsBodyStatus =[NSNumber numberWithInt:currentBellTag];
            
        }
        
        NSMutableArray *rabbitTextureArray=[[NSMutableArray alloc] initWithCapacity:3];
        
        for (int i=1; i<=3; i++) {
            SKTexture *textureRabbit=[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"bell%02d",i]];
            [rabbitTextureArray addObject:textureRabbit];
        }
        SKAction *action = [SKAction animateWithTextures:rabbitTextureArray timePerFrame:0.8];
        [bellNode runAction:[SKAction repeatActionForever:action]];
        
        BellCount++;
        NSLog(@"BellCount=%d bell.y=%f currentBellY=%f",BellCount,bellNode.position.y,currentBellY);
        
    }
    
    
    //    else
    //    {
    //
    //
    //        CRBellSpriteNode *sprite = [[CRBellSpriteNode alloc] initWithImageNamed:@"Spaceship"];
    //        bellNode = sprite;
    //        sprite.size = BELL_SIZE;
    //        sprite.xScale = 0.5;
    //        sprite.yScale = 0.5;
    //        //    sprite.position = CGPointMake(xValue, yValue+100);
    //        sprite.name = [NSString stringWithFormat:@"%@%d",BELL_NODE_NAME,currentBellTag];
    //        sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10 center:CGPointMake(0.0f, 0.0)];
    //        sprite.physicsBody.affectedByGravity = NO;
    //        //    SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
    //        sprite.physicsBody.categoryBitMask =4;
    //        sprite.physicsBody.collisionBitMask = 3;
    //        sprite.physicsBody.contactTestBitMask = 1;
    //        sprite.physicsBody.density = 1;
    //        sprite.physicsBody.PPBellPhysicsBodyStatus =[NSNumber numberWithInt:currentBellTag];
    //
    //
    //
    //        if (bellNode != nil) {
    //            [bellNode  removeAllActions];
    //        }
    //
    //
    //        //    if(random()%2==1) bellNode.xScale = 1.0f;
    //
    //
    //        if (random()%13==1) {
    //            bellNode.type = kBellTypeTypeSpecial;
    //            //换成特殊铃铛
    //        }
    //        else{
    //            bellNode.type = kBellTypeTypeNormal;
    //
    //            //设置普通铃铛
    //        }
    //
    //
    //        float x;
    //        CGSize size = bellNode.size;
    //        if(currentBellY == kMinBellsStep) {
    //            x = self.size.width/2.0f;
    //        } else {
    //            x = random() % (self.size.width-(int)size.width) + size.width/2;
    //        }
    //
    //
    //        bellNode.position = CGPointMake(x,currentBellY);
    //        bellNode.hidden = NO;
    //        bellNode.physicsBody.dynamic = NO;
    //
    //        BellCount++;
    //        NSLog(@"BellCount=%d bell.y=%f currentBellY=%f",BellCount,bellNode.position.y,currentBellY);
    //
    //        [self addChild:bellNode];
    //
    //
    //
    //    }
    //
    
    
    
    //	NSLog(@"BellCount = %d",BellCount);
    
    
}
#pragma mark Game over


-(void)gameOver
{
    
    NSLog(@"game over!!!!!");
    [self stopMotionManager];
    
    self.paused = YES;
    
    
    if (stopView!=nil) {
        [stopView removeFromSuperview];
        stopView = nil;
    }
    
    
    stopView = [[UIView alloc] initWithFrame:self.view.frame];
    UIView *backView= [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, stopView.frame.size.width, stopView.frame.size.height)];
    [backView setBackgroundColor:[UIColor blackColor]];
    backView.alpha = 0.5;
    [stopView addSubview:backView];
    
//    MyScreenKit *screen = [MyScreenKit getInstance];

    
    UILabel *currentScoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.size.width/4, 60.0f, self.size.width/2.0f, 49)];
    if ([[MyScreenKit getInstance]->lang isEqualToString:@"ch"]) {
        
        [currentScoreLabel setText:[NSString stringWithFormat:@"本次成绩：%.1fm",totalScores]];
        
    }else
    {
        
        [currentScoreLabel setText:[NSString stringWithFormat:@"current score：%.1fm",totalScores]];
    }
    
    currentScoreLabel.textAlignment = 1;
    currentScoreLabel.font = [UIFont boldSystemFontOfSize:16];
    [currentScoreLabel sizeToFit];
    [currentScoreLabel setTextColor:[UIColor whiteColor]];
    [stopView addSubview:currentScoreLabel];
    
    
    
    
    UILabel *maxScoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.size.width/4, currentScoreLabel.frame.size.height+currentScoreLabel.frame.origin.y+30, self.size.width/2.0f, 49)];
    [maxScoreLabel setTextColor:[UIColor whiteColor]];
    maxScoreLabel.textAlignment = 1;
   
    NSNumber *maxHistory = [self getMaxHistoryScore];
    
    if ([maxHistory floatValue]>=totalScores) {
        
        if ([[MyScreenKit getInstance]->lang isEqualToString:@"ch"]) {
            [maxScoreLabel setText:[NSString stringWithFormat:@"最好成绩：%.1fm",[maxHistory floatValue]]];

        }else
        {
            [maxScoreLabel setText:[NSString stringWithFormat:@"Best Score：%.1fm",[maxHistory floatValue]]];
        }
        
    }else
    {
        
        
        if ([[MyScreenKit getInstance]->lang isEqualToString:@"ch"]){
            
            UIAlertView *alertBreakRecord=[[UIAlertView alloc] initWithTitle:@"恭喜" message:@"恭喜您超越了自己，打破了纪录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertBreakRecord show];
            
            
            [maxScoreLabel setText:[NSString stringWithFormat:@"最好成绩：%.1fm",totalScores]];
            [self setMaxHistoryScore];
            
        }else
        {
            
            UIAlertView *alertBreakRecord=[[UIAlertView alloc] initWithTitle:@"Congratulation!" message:@"Congratulation! You have break your record!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertBreakRecord show];
            
            
             [maxScoreLabel setText:[NSString stringWithFormat:@"Best Score：%.1fm",[maxHistory floatValue]]];
            
            [self setMaxHistoryScore];
        }
            
    }
    
    maxScoreLabel.font = [UIFont boldSystemFontOfSize:16];
    [maxScoreLabel sizeToFit];
    [stopView addSubview:maxScoreLabel];
    
    
    
    UIButton *buttonRestart=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRestart addTarget:self action:@selector(buttonRestartBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [buttonRestart setTitle:@"重新开始" forState:UIControlStateNormal];
    [buttonRestart setBackgroundColor:[UIColor clearColor]];
    [buttonRestart setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",@"retrybtn",[MyScreenKit getInstance]->lang]] forState:UIControlStateNormal];

    [buttonRestart setFrame:CGRectMake((self.size.width-160.0f)/2, maxScoreLabel.frame.size.height+maxScoreLabel.frame.origin.y+30, 160.0f, 50.0)];
    [stopView addSubview:buttonRestart];
    
    
    
    UIButton *buttonBackToMenu=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBackToMenu addTarget:self action:@selector(buttonBackToMenuBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [buttonBackToMenu setTitle:@"返回到主菜单" forState:UIControlStateNormal];
    [buttonBackToMenu setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",@"menubtn",[MyScreenKit getInstance]->lang]] forState:UIControlStateNormal];
    [buttonBackToMenu setBackgroundColor:[UIColor clearColor]];
    [buttonBackToMenu setFrame:CGRectMake((self.size.width-160.0f)/2, buttonRestart.frame.size.height+buttonRestart.frame.origin.y+30, 160.0f, 50.0)];
    [stopView addSubview:buttonBackToMenu];
    
    
    [stopView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:stopView];
    
    [self setHistoryScore];
    
}

-(void)setHistoryScore
{
    
    NSUserDefaults *userDef =[NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array=[[NSMutableArray alloc] initWithArray:[userDef objectForKey:HISTORY_SCORES_KEY]];
    [array addObject:[NSString stringWithFormat:@"%.1f",totalScores]];
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        if ([obj1 intValue] < [obj2 intValue]){
            return NSOrderedDescending;
        }
        if ([obj1 intValue] > [obj2 intValue]){
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    
    
    if ([sortedArray count]>10) {
        
        NSMutableArray *arrayTenObj=[[NSMutableArray alloc] initWithCapacity:10];
        for (int i=0; i<10; i++) {
            [arrayTenObj addObject:[sortedArray objectAtIndex:i]];
        }
        
        [userDef setObject:arrayTenObj forKey:HISTORY_SCORES_KEY];
        
    }else
    {
        [userDef setObject:sortedArray forKey:HISTORY_SCORES_KEY];
        
    }
    
}

-(NSNumber *)getMaxHistoryScore
{
    
    NSNumber *maxHistoreScore = [[NSUserDefaults standardUserDefaults] objectForKey:kUserMaxScores];
    return maxHistoreScore;
    
}

-(void)setMaxHistoryScore
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:totalScores] forKey:kUserMaxScores];
}
-(void)stopMotionManager
{
    [motionManager stopAccelerometerUpdates];
}
-(void)startMotionManager
{
    
    motionManager = [[CMMotionManager alloc] init];
    if (!motionManager.accelerometerAvailable) {
        NSLog(@"没有加速计");
    }
    
    motionManager.accelerometerUpdateInterval = 0.02; // 告诉manager，更新频率是100Hz
    [motionManager startDeviceMotionUpdates];
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *latestAcc, NSError *error)
     {
         
         CMAccelerometerData *newestAccel = motionManager.accelerometerData;
         double accelerationX = newestAccel.acceleration.x;
         
         //             double accelerationY = newestAccel.acceleration.y;
         //             double accelerationZ = newestAccel.acceleration.z;
         //             NSLog(@"accelerationX=%f accelerationY=%f accelerationZ=%f",accelerationX,accelerationY,accelerationZ);
         
         rabbitNode.position = CGPointMake(rabbitNode.position.x+accelerationX*20, rabbitNode.position.y);
         
         //判断rabbit是否有位置偏移
         if(accelerationX < -0.05f ) {
             birdLookingRight = NO;
             rabbitNode.xScale = 1.0f;
         }else if(accelerationX > 0.05f){
             birdLookingRight = YES;
             rabbitNode.xScale = -1.0f;
         }
         
         
     }];
    
    
    
}

#pragma mark click methods
-(void)stopBtnClick
{
    
    self.paused = YES;
    [self stopMotionManager];
    
    if (stopView!=nil) {
        [stopView removeFromSuperview];
        stopView = nil;
    }
    
    stopView = [[UIView alloc] initWithFrame:self.view.frame];
    
    
    
    UIView *backView= [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, stopView.frame.size.width, stopView.frame.size.height)];
    [backView setBackgroundColor:[UIColor whiteColor]];
    backView.alpha = 0.5;
    [stopView addSubview:backView];
    
    UIButton *buttonContinue=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonContinue addTarget:self action:@selector(continueBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [buttonContinue setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",@"continuebtn",[MyScreenKit getInstance]->lang]] forState:UIControlStateNormal];
//    [buttonContinue setTitle:@"继续" forState:UIControlStateNormal];
    [buttonContinue setBackgroundColor:[UIColor clearColor]];
    [buttonContinue setFrame:CGRectMake(80.0f, 120.0f, 160.0f, 49.0)];
    [stopView addSubview:buttonContinue];
    
    
    
    UIButton *buttonRestart=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRestart addTarget:self action:@selector(buttonRestartBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [buttonRestart setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",@"retrybtn",[MyScreenKit getInstance]->lang]] forState:UIControlStateNormal];
//    [buttonRestart setTitle:@"重新开始" forState:UIControlStateNormal];
    [buttonRestart setBackgroundColor:[UIColor clearColor]];
    [buttonRestart setFrame:CGRectMake(80.0f, 200.0f, 160.0f, 49.0)];
    [stopView addSubview:buttonRestart];
    
    
    
    UIButton *buttonBackToMenu=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBackToMenu addTarget:self action:@selector(buttonBackToMenuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [buttonBackToMenu setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",@"menubtn",[MyScreenKit getInstance]->lang]] forState:UIControlStateNormal];
//    [buttonBackToMenu setTitle:@"返回到主菜单" forState:UIControlStateNormal];
    [buttonBackToMenu setBackgroundColor:[UIColor clearColor]];
    [buttonBackToMenu setFrame:CGRectMake(80.0f, 280.0f, 160.0f, 49.0)];
    [stopView addSubview:buttonBackToMenu];
    
    
    [stopView setBackgroundColor:[UIColor clearColor]];
  
    [self.view addSubview:stopView];
    
}

-(void)continueBtnClick
{
    
    
    
    [self startMotionManager];
    
    if (stopView) {
        [stopView removeFromSuperview];
        stopView = nil;
    }
    
    self.paused = NO;
    
    
}

-(void)buttonRestartBtnClick
{
    
    [motionManager startAccelerometerUpdates];
    
    
    if (stopView) {
        [stopView removeFromSuperview];
        stopView = nil;
    }
    
    [self restartGame];
    
    
    
}
-(void)buttonBackToMenuBtnClick
{
    if (stopView) {
        [stopView removeFromSuperview];
        stopView = nil;
    }
    [self.view presentScene:previousScene];
}


-(CRBellSpriteNode *)getBellNodeWithName:(NSString *)bellName
{
    CRBellSpriteNode *bellNode =(CRBellSpriteNode *)[self childNodeWithName:bellName];
    return bellNode;
}



-(void)dealBackGroundMove:(int)indexValue
{
    
    
    [contentBellNode runAction:[SKAction moveToY:-contactedIndex*BELL_DIRECTION_VALUE+self.size.height/2.0f duration:0.5]];
    
    //        [self enumerateChildNodesWithName:BELL_NODE_NAME usingBlock:^(SKNode *node,BOOL *stop){
    //
    //            NSLog(@"bell: x:%f y:%f",node.position.x,node.position.y);
    //
    //            //        node.position = CGPointMake(node.position.x, 40);
    //            [node runAction:[SKAction moveBy:CGVectorMake(0.0f, -40.0f) duration:0.5]];
    //            NSLog(@"bell moved: x:%f y:%f",node.position.x,node.position.y);
    //
    //        }];
    
    
    
}

#pragma mark SKScene delegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    
    //    NSLog(@"bodyA catogry=%d collision=%d test=%d",contact.bodyA.categoryBitMask,contact.bodyA.collisionBitMask,contact.bodyA.contactTestBitMask);
    //    NSLog(@"bodyB catogry=%d collision=%d test=%d",contact.bodyB.categoryBitMask,contact.bodyB.collisionBitMask,contact.bodyB.contactTestBitMask);
    

    if (contact.bodyA.categoryBitMask==4||contact.bodyB.categoryBitMask==4) {
        
        if (isStart==NO) {
            isStart =YES;
            totalScores+=50;
        }
        
        if (contact.bodyA == rabbitNode.physicsBody) {
            
            
            //        currentBellTag =[contact.bodyB.PPBellPhysicsBodyStatus intValue];
            //        [self resetEveryBell];//重置铃铛位置
            //
            //        NSLog(@"currentBellTag=%d",currentBellTag);
            //
            SKNode *node = [self childNodeWithName:[NSString stringWithFormat:@"%@%@",BELL_NODE_NAME,contact.bodyB.PPBellPhysicsBodyStatus]];
            node.hidden = YES;
            [self initRemoveBellAnimationNode:CGPointMake(node.position.x, node.position.y-10)];
            node.physicsBody = nil;
            //        [contact.bodyB.node removeFromParent];
            
            //        contact.bodyB. = nil;
            //            NSLog(@"current index=%@",contact.bodyB.PPBellPhysicsBodyStatus);
            
            rabbitNode.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
            [rabbitNode.physicsBody applyImpulse:CGVectorMake(0.0f, BELL_IMPULSE_VALUE)];
            //        rabbitNode.physicsBody.velocity = CGVectorMake(0, BELL_IMPULSE_VALUE);
            
            contactedIndex = [contact.bodyB.PPBellPhysicsBodyStatus intValue];
            //            [self dealBackGroundMove:contactedIndex];
            
            
        }else
        {
            
            //        currentBellTag =[contact.bodyA.PPBellPhysicsBodyStatus intValue];
            //        [self resetEveryBell];//重置铃铛位置
            //        NSLog(@"currentBellTag=%d",currentBellTag);
            //
            SKNode *node = [self childNodeWithName:[NSString stringWithFormat:@"%@%@",BELL_NODE_NAME,contact.bodyA.PPBellPhysicsBodyStatus]];
            node.hidden = YES;
            [self initRemoveBellAnimationNode:CGPointMake(node.position.x, node.position.y-10)];

            node.physicsBody = nil;
            contact.bodyA.node.hidden = YES;
            //        [contact.bodyA.node removeFromParent];
            //            NSLog(@"current index=%@",contact.bodyA.PPBellPhysicsBodyStatus);
            
            
            rabbitNode.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
            [rabbitNode.physicsBody applyImpulse:CGVectorMake(0.0f, BELL_IMPULSE_VALUE)];
            //        rabbitNode.physicsBody.velocity = CGVectorMake(0, BELL_IMPULSE_VALUE);
            
            
            //            contactedIndex = [contact.bodyA.PPBellPhysicsBodyStatus intValue];
            //            [self dealBackGroundMove:contactedIndex];
            
        }
        
        if (!musicOff) {
            [self playSoundWithName:@"bird_ring.caf"];

        }
        
        
        [altitudeValueLebel setText:[NSString stringWithFormat:@"%.1f",totalScores]];
        [altitudeValueLebel runAction:[SKAction scaleTo:2.5f duration:0.1] completion:^{
            altitudeValueLebel.xScale = 1;
            altitudeValueLebel.yScale = 1;
        }];
        
        return;
    }
    
    if ((contact.bodyA.categoryBitMask==1&&contact.bodyB.categoryBitMask==10)||(contact.bodyA.categoryBitMask==10&&contact.bodyB.categoryBitMask==1)) {
        
        if (isStart) {
//            [self gameOver];
            [self performSelector:@selector(gameOver) withObject:nil afterDelay:0.5];
        }
        
    }
    NSLog(@"contactedIndex=%d",contactedIndex);
    
    
}

-(void)didSimulatePhysics
{
    
    CGSize bird_size = rabbitNode.size;
    float max_x = self.size.width-bird_size.width/2;
    float min_x = 0+bird_size.width/2;
    
    if(rabbitNode.position.x>max_x) rabbitNode.position = CGPointMake(max_x, rabbitNode.position.y);
    if(rabbitNode.position.x<min_x) rabbitNode.position = CGPointMake(min_x, rabbitNode.position.y);
    
    
    //    NSLog(@"size.wid=%f heg=%f",rabbitNode.size.width,rabbitNode.size.height);
    
    
    if (isStart) {
        
        if (rabbitNode.position.y>284.0f) {
            
            
            float delta = rabbitNode.physicsBody.velocity.dy/60;
            
            (totalScores<(totalScores+delta))?totalScores+=delta:totalScores;
            
            
            //        CGPoint posTmp = rabbitNode.position;
            //        posTmp = CGPointMake(posTmp.x, posTmp.y-delta);
            currentBellY -= delta;
            
            //        if (fallRange>0) {
            //            fallRange-=delta;
            //        }
            //        if (fallRange<=0) {
            
            
            
            rabbitNode.position = CGPointMake(rabbitNode.position.x, 284.0f);
            NSLog(@"delta=%f vel.y=%f",delta,rabbitNode.physicsBody.velocity.dy);
            
            [self enumerateChildNodesWithName:STAR_NODE_NAME usingBlock:^(SKNode *node,BOOL *stop){
                
                node.position = CGPointMake(node.position.x, node.position.y-delta);
                
            }];
            
            
            SKSpriteNode *bottomWall = (SKSpriteNode *)[self childNodeWithName:WALL_NODE_NAME];
            bottomWall.position = CGPointMake(bottomWall.position.x, bottomWall.position.y-delta);
            
            if (bottomWall.position.y<-900.0f) {
                bottomWall.position = CGPointMake(bottomWall.position.x, -900.0f);
            }
            
            for (int i=0; i<kNumBells; i++) {
                
                //            CRBellSpriteNode *bellNode = [self getBellNodeWithName:[NSString stringWithFormat:@"%@%d",BELL_NODE_NAME,i]];
                [self enumerateChildNodesWithName:[NSString stringWithFormat:@"%@%d",BELL_NODE_NAME,i+kBellsStartTag] usingBlock:^(SKNode *node,BOOL *stop){
                    if (node.position.y<-300) {
                        
                        currentBellTag = i+kBellsStartTag;
                        
                        [self resetEveryBell];//重置铃铛位置
                        
                    }else
                    {
                        
                        node.position = CGPointMake(node.position.x, node.position.y-delta);
                    }
                }];
                
            }
            
            //        }
            
        }else if(rabbitNode.position.y<100)
        {
            
            
            float delta = rabbitNode.physicsBody.velocity.dy/60;
            //		float delta = 5;
            (totalScores<(totalScores+delta))?totalScores+=delta:totalScores;
            
            rabbitNode.position = CGPointMake(rabbitNode.position.x, 100.0f);
            fallRange +=delta;
            
            currentBellY -= delta;
            
            
            [self enumerateChildNodesWithName:STAR_NODE_NAME usingBlock:^(SKNode *node,BOOL *stop){
                
                node.position = CGPointMake(node.position.x, node.position.y-delta);
                
            }];
            
            
            __block float minY = 960;
            
            for(int t=0; t < kNumBells; t++) {
                
                [self enumerateChildNodesWithName:[NSString stringWithFormat:@"%@%d",BELL_NODE_NAME,t+kBellsStartTag] usingBlock:^(SKNode *node,BOOL *stop){
                    if (node.position.y<-node.frame.size.height/2-300) {
                        
                        CGPoint pos = node.position;
                        pos = CGPointMake(pos.x,pos.y+delta);
                        node.position = pos;
                        if (minY>node.position.y) {
                            minY=node.position.y;
                        }
                        
                    }else
                    {
                        
                        node.position = CGPointMake(node.position.x, node.position.y-delta);
                    }
                }];
                
            }
            
            if (minY>200) {
                
                SKNode *wallNode = [self childNodeWithName:WALL_NODE_NAME];
                wallNode.position = CGPointMake(wallNode.position.x, wallNode.position.y-delta);
                if (wallNode.position.y>100) {
                    wallNode.position =CGPointMake(wallNode.position.x, 100);
                }
            }
        }
    }
    
    [altitudeValueLebel setText:[NSString stringWithFormat:@"%.1fm",totalScores]];
    
}


-(void)didEndContact:(SKPhysicsContact *)contact
{
    
    
}


-(void)didMoveToView:(SKView *)view {
    
    /* Setup your scene here */
    
    [self initRabbitNode];
    
    UIButton *buttonStop=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonStop addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [buttonStop setImage:[UIImage imageNamed:@"stopbtn"] forState:UIControlStateNormal];
    buttonStop.tag = 10000;
    [buttonStop setBackgroundColor:[UIColor clearColor]];
    [buttonStop setFrame:CGRectMake(self.size.width - 40.0f, 0.0f, 40.0f, 40.0)];
    [self.view addSubview:buttonStop];
    
    


}
- (void)willMoveFromView:(SKView *)view
{
    UIButton *stopBtn = (UIButton *)[self.view viewWithTag:10000];
    if (stopBtn) {
        [stopBtn removeFromSuperview];
        stopBtn = nil;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if (!isStart) {
        NSLog(@"%f",rabbitNode.physicsBody.velocity.dy);
        
        if (fabsf(rabbitNode.physicsBody.velocity.dy)<0.01) {
            [rabbitNode.physicsBody applyImpulse:CGVectorMake(0.0f, BELL_IMPULSE_VALUE)];
        }
        
    }
    
    
}

-(void)update:(CFTimeInterval)currentTime {
    
    
    
    /* Called before each frame is rendered */
}

@end

