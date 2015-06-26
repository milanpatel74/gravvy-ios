//
//  GRVVideoTableViewCell.h
//  Gravvy
//
//  Created by Nnoduka Eruchalu on 6/25/15.
//  Copyright (c) 2015 Nnoduka Eruchalu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRVUserAvatarView.h"
#import "GRVPlayerView.h"

/**
 * GRVVideoTableViewCell represents a row in a table view controller used
 * to display an video's summary info and play associated clips.
 */
@interface GRVVideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet GRVUserAvatarView *ownerAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *playsCountLabel;
@property (weak, nonatomic) IBOutlet GRVPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;


@end
