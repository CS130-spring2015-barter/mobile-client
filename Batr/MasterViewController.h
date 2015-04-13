//
//  MasterViewController.h
//  Bartr
//
//  Created by admin on 4/12/15.
//  Copyright (c) 2015 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

