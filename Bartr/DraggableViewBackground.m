//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14. Edited by Synthia Ling.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "BrtrCardItem.h"
#import "BrtrItemViewController.h"
#import "BrtrDataSource.h"
#import "JCDCoreData.h"

@implementation DraggableViewBackground {
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* checkButton;
    UIButton* xButton;
}

//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
//static const float CARD_HEIGHT = 420; //%%% height of the draggable card
//static const float CARD_WIDTH = 290; //%%% width of the draggable card

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame andDelegate:(NSObject<DraggableViewBackgroundDelegate>*)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [super layoutSubviews];
        [self setupView];
        //exampleCardLabels=[self.delegate getMultipleCardsUsingDelegate:self];
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        [self loadCards];
    }
    return self;
}

-(void) didReceiveData:(id)data response:(NSURLResponse *)response
{
    NSArray *cards = (NSArray *)data;
    NSMutableSet *newCards = [[NSMutableSet alloc] init];
    NSSet *currCards = [[NSSet alloc] initWithArray:exampleCardLabels];
    [newCards addObjectsFromArray:cards];
    [newCards minusSet:currCards];
    self.exampleCardLabels = [[newCards copy] allObjects];
    
    [self loadCards];
    [self setNeedsDisplay];
}

- (void) fetchingDataFailed:(NSError *)error;
{
    //NSLog(@"BrtrSwipeyView: Error %@; %@", error, [error localizedDescription]);
    NSLog(@"BrtrSwipeyView: Error when trying to fetch cards");
}


//%%% sets up the extra buttons on the screen
-(void)setupView
{

    int screen_height=[[UIScreen mainScreen] bounds].size.height;
    int screen_width= [[UIScreen mainScreen] bounds].size.width;
    
    int button_size=55;
    int button_separation=70;
    int button_y=screen_height - screen_height/4.5;
    int xButton_x=(screen_width/2) - ( button_size + (button_separation/2) );
    int checkButton_x= xButton_x + button_size+button_separation;
    
    self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    
    
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(xButton_x, button_y, button_size, button_size)];
    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(checkButton_x, button_y, button_size, button_size)];
    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:xButton];
    [self addSubview:checkButton];
}


// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    int screen_height=[[UIScreen mainScreen] bounds].size.height;
    int screen_width= [[UIScreen mainScreen] bounds].size.width;
    
    int card_height=screen_height-screen_height/3;
    int card_width=screen_width -screen_width/5;
    
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((screen_width - card_width)/2, (screen_height - card_height)/2-(screen_height-card_height)/4, card_width, card_height)];
    
    draggableView.image.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPicture:)];
    [draggableView.image addGestureRecognizer:tap];

    
    draggableView.item= [exampleCardLabels objectAtIndex:index];
    
    draggableView.image.image = [UIImage imageWithData:draggableView.item.picture];
    draggableView.name.text=draggableView.item.name;
    if (draggableView.item.info == nil) {
        draggableView.info.text=@"no item information";
    } else {
        draggableView.info.text=draggableView.item.info;
    }
    
     
    
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([exampleCardLabels count] > 0) {
        NSInteger numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[exampleCardLabels count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

//warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    DraggableView *itemCard = (DraggableView *)card;
    NSMutableArray *mut_example_cards = [NSMutableArray arrayWithArray:exampleCardLabels];
    [mut_example_cards removeObject:itemCard.item];
    exampleCardLabels = [mut_example_cards copy];
    
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    [context deleteObject:itemCard.item];
    
    [self.delegate itemSwipedLeft:itemCard.item usingDelegate:self];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
//    else {
//        exampleCardLabels=[self.delegate getMultipleCardsUsingDelegate:self];
//    }
    if ([exampleCardLabels count] == 0) {
        exampleCardLabels=[self.delegate getMultipleCardsUsingDelegate:self];
    }
}

//warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    DraggableView *itemCard = (DraggableView *)card;
    NSMutableArray *mut_example_cards = [NSMutableArray arrayWithArray:exampleCardLabels];
    [mut_example_cards removeObject:itemCard.item];
    exampleCardLabels = [mut_example_cards copy];
    
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    [context deleteObject:itemCard.item];
    
    [self.delegate itemSwipedRight:itemCard.item usingDelegate:self];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
//    else {
//        exampleCardLabels=[self.delegate getMultipleCardsUsingDelegate:self];
//    }
    if ([exampleCardLabels count] == 0) {
        exampleCardLabels=[self.delegate getMultipleCardsUsingDelegate:self];
    }
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

-(void)clickPicture:(UIGestureRecognizer *)tap
{
    DraggableView *dragView = [loadedCards firstObject];
    [self.delegate userClickedItem:dragView.item];
}


@end