//
//  CRMainMenuScene.m
//  ChristmasRabbit
//
//  Created by xiefei on 14/12/9.
//  Copyright (c) 2014年 xiefei. All rights reserved.
//

#import "CRMainMenuScene.h"
#import "CRGameScene.h"
#import "CRHistoryScoresScene.h"
#import "MyScreenKit.h"
#import <AVFoundation/AVFoundation.h>
#define USER_DEFAULT_KEY @"userdefaultkeyani"

static NSString *stringMenu[]={
   
    @"开始游戏",
    @"历史成绩",
    @"兔子商城",
    @"设置"
    
};

static NSString *stringBtnMenu[]={
    
    @"beginbtn",
    @"historyscoresbtn",
    @"removeadbtn",
    @"turnoffmusic"
    
};

#define PLAY_BUTTON_TAG 200
@interface CRMainMenuScene()
{
    
    UIView *menuContentView;
    BOOL musicOff;
}
@property(nonatomic,strong)AVAudioPlayer * bgmPlayer;

@end


@implementation CRMainMenuScene
@synthesize bgmPlayer;
-(id)initWithSize:(CGSize)size
{
    self=[super initWithSize:size];
    
    if (self) {
        
        musicOff= NO;
        haveShow = NO;
        
        SKSpriteNode *backNode =[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"gamesceneback"]];
        backNode.zPosition = -2;
        backNode.size = self.size;
        backNode.position = CGPointMake(self.size.width/2.0f, self.size.height/2.0f);
        [self addChild:backNode];
    }
    return self;
}
#pragma mark SKScene delegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    
    
}

-(void)didSimulatePhysics
{
    
    
    
}

-(void)didEndContact:(SKPhysicsContact *)contact
{
    
    
    
}
-(void)startBackGroundMusic
{
    if (self.bgmPlayer == nil) {
        NSString *bgmPath = [[NSBundle mainBundle] pathForResource:@"background_music" ofType:@"mp3"];
        self.bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:bgmPath] error:NULL];
        self.bgmPlayer.numberOfLoops = -1;
        [self.bgmPlayer prepareToPlay];
        [self.bgmPlayer play];
        
    }else{
    
        [self.bgmPlayer play];

    }
}
-(void)stopBackGroundMusic
{
    if (self.bgmPlayer) {
        [self.bgmPlayer stop];
    }
}
-(void)didMoveToView:(SKView *)view {
    
    /* Setup your scene here */
    [self setBackgroundColor:[UIColor orangeColor]];
    
    [self startBackGroundMusic];
    if (!haveShow) {
        NSString *stringuser = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY];
        if ([stringuser length]==0) {
            SKSpriteNode *imageLauchNode= [SKSpriteNode spriteNodeWithImageNamed:@"Launch01"];
            imageLauchNode.position = CGPointMake(self.size.width/2.0f, self.size.height/2.0f);
            imageLauchNode.size = self.size;
            NSMutableArray *animationImagesArray=[[NSMutableArray alloc] init];
            for (int i=1; i<17;i++) {
                //        UIImage *frameImage=[UIImage imageNamed:[NSString stringWithFormat:@"Launch%02d.png",i]];
                SKTexture *frameTexture=[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Launch%02d.png",i]];
                [animationImagesArray addObject:frameTexture];
                
            }
            SKAction *actionShowRabbit = [SKAction animateWithTextures:animationImagesArray timePerFrame:0.2];
            [self addChild:imageLauchNode];
            
            [imageLauchNode runAction:actionShowRabbit completion:^{
                [self performSelector:@selector(addFiveFrameAnimation:) withObject:imageLauchNode afterDelay:3];
                
            }];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"haveshow" forKey:USER_DEFAULT_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            haveShow = YES;

        }else
        {
            haveShow = YES;
            [self addMenuBtn:nil];
        }
            }else{
        
        [self addMenuBtn:nil];
    
    }
    
}

-(void)addFiveFrameAnimation:(SKSpriteNode *)spriteBtn
{
    
    NSMutableArray *animationImagesArrayFive=[[NSMutableArray alloc] init];
    for (int i=17; i<23;i++) {
        //        UIImage *frameImage=[UIImage imageNamed:[NSString stringWithFormat:@"Launch%02d.png",i]];
        SKTexture *frameTexture=[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Launch%02d.png",i]];
        [animationImagesArrayFive addObject:frameTexture];
        
    }
    SKAction *actionShowRabbitFive = [SKAction animateWithTextures:animationImagesArrayFive timePerFrame:1];
    [spriteBtn runAction:actionShowRabbitFive completion:^{
        
        [self performSelector:@selector(addMenuBtn:) withObject:spriteBtn afterDelay:3];
        
    }];

    
}

-(void)addMenuBtn:(SKSpriteNode *)spriteAni
{
    if (spriteAni) {
        [spriteAni removeFromParent];

    }
    
    
    if (menuContentView!=nil) {
        [menuContentView removeFromSuperview];
    }
    
    menuContentView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.size.width, self.size.height)];
    [menuContentView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:menuContentView];
    
    for (int i =0; i<4; i++) {
        UIButton *playButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setFrame:CGRectMake((self.size.width-80.0f)/2.0f, 80.0f*i+100.0f, 80.0f, 40.0f)];
        
        switch (i) {
            case 0:
            {
                [playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",stringBtnMenu[i],[MyScreenKit getInstance]->lang]] forState:UIControlStateNormal];
                [playButton setFrame:CGRectMake((self.size.width-160.0f)/2.0f, 80.0f*i+100.0f, 160.0f, 49.0f)];
                
                //                [playButton setImage:[UIImage imageNamed:@"rabbit"] forState:UIControlStateNormal];
                
                //                [playButton setBackgroundColor:[UIColor redColor]];
                NSLog(@"image=%@",[NSString stringWithFormat:@"%@_%@",stringBtnMenu[i],[MyScreenKit getInstance]->lang]);
                
            }
                break;
            case 1:
            {
                [playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",stringBtnMenu[i],[MyScreenKit getInstance]->lang]] forState:UIControlStateNormal];
                [playButton setFrame:CGRectMake((self.size.width-160.0f)/2.0f, 80.0f*i+100.0f, 160.0f, 49.0f)];
                
            }
                break;
            case 2:
            {
                [playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",stringBtnMenu[i],@"en"]] forState:UIControlStateNormal];
                [playButton setFrame:CGRectMake((self.size.width-40.0f)/2.0f, 80.0f*i+100.0f, 40.0f, 40.0f)];
                playButton.hidden = YES;
                
            }
                break;
            case 3:
            {
                [playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@",stringBtnMenu[i],@"02"]] forState:UIControlStateNormal];
                [playButton setFrame:CGRectMake((self.size.width-40.0f)/2.0f, 80.0f*i+100.0f, 40.0f, 40.0f)];
                
                
            }
                break;
                
            default:
                break;
        }
        
        playButton.tag = i + PLAY_BUTTON_TAG;
        [playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [menuContentView addSubview:playButton];
        
    }
}
-(void)playButtonClick:(UIButton *)button
{
    

    
    switch (button.tag - PLAY_BUTTON_TAG) {
        case 0:
        {
            [menuContentView removeFromSuperview];
            menuContentView = nil;
            [self beginNewGame];
        }
            break;
        case 1:
        {
            
            [menuContentView removeFromSuperview];
            menuContentView = nil;
            [self lookHistoryScore];
            
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            if (musicOff) {
                musicOff = NO;
                [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@",stringBtnMenu[3],@"02"]] forState:UIControlStateNormal];
                [self startBackGroundMusic];

            }else
            {
                musicOff = YES;
                [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@",stringBtnMenu[3],@"01"]] forState:UIControlStateNormal];
                [self stopBackGroundMusic];


            }
        }
            break;
            
        default:
            break;
    }
    
}
-(void)beginNewGame
{
    
    // Create and configure the scene.
    CRGameScene *scene = [[CRGameScene alloc] initWithSize:self.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene->musicOff = musicOff;
    scene->previousScene = self;
    // Present the scene.
    [self.view presentScene:scene];
    
}

-(void)lookHistoryScore
{
    
    // Create and configure the scene.
    CRHistoryScoresScene *scene = [[CRHistoryScoresScene alloc] initWithSize:self.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene->previousScene = self;
    // Present the scene.
    [self.view presentScene:scene];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    
    
}

-(void)update:(CFTimeInterval)currentTime {
    
    
    
    /* Called before each frame is rendered */
}


@end
