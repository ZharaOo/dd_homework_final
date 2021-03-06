//
//  PhotosCollectionViewController.m
//  dd_homework_final
//
//  Created by babi4_97 on 23.11.2017.
//  Copyright © 2017 Ivan Babkin. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "ShowPhotoViewController.h"
#import "ParamPhotosService.h"
#import "PhotoImage.h"
#import "SearchContent.h"

#define SHOW_VIEW_PHOTO_ID @"viewPhotoSegue"

@interface PhotosCollectionViewController () <ParamPhotosDelegate> {
    ParamPhotosService *service;
    
    NSDictionary *chosenImageSizes;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"CollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.navigationItem.title = self.selectedContent.content;
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.center = CGPointMake(self.collectionView.frame.size.width / 2, self.collectionView.frame.size.height / 2);
    [self.indicator startAnimating];
    [self.collectionView addSubview:self.indicator];
    
    self.photos = [[NSMutableArray alloc] init];
    
    service = [[ParamPhotosService alloc] init];
    service.delegate = self;
    [self loadPhotos];
}

- (void)loadPhotos {
    if (self.selectedContent.type == ContentTypeTag) {
        [service loadTagPhotos:self.selectedContent.content];
    } else if (self.selectedContent.type == ContentTypeText) {
        [service loadTextPhotos:self.selectedContent.content];
    }
}

- (void)addPhotoImage:(PhotoImage *)photoImage {
    [self.photos addObject:photoImage];
    [self.collectionView reloadData];
}

- (void)updateNumberOfPhotos {
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    
    [self.collectionView reloadData];
}

- (void)errorLoadingDataWithTitle:(NSString *)title description:(NSString *)errorDescription {
    if (self.view.window) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:errorDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return service.nubmerOfPhotos;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (indexPath.row < self.photos.count) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        PhotoImage *photoImage = self.photos[indexPath.row];
        imgView.image = photoImage.image;
        [cell addSubview:imgView];
    } else {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        indicator.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
        [cell addSubview:indicator];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.photos.count) {
        return YES;
    } else {
        return NO;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoImage *photoImage = self.photos[indexPath.row];
    chosenImageSizes = photoImage.sizes;
    [self performSegueWithIdentifier:SHOW_VIEW_PHOTO_ID sender:self];
}

 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqual:SHOW_VIEW_PHOTO_ID]) {
         ShowPhotoViewController *dvc = (ShowPhotoViewController *)segue.destinationViewController;
         dvc.sizes = chosenImageSizes;
     }
 }

@end
