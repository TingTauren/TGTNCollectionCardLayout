//
//  ViewController.m
//  TGTNCollectionCardLayout
//
//  Created by Mac on 2022/4/12.
//

#import "ViewController.h"

#import "TGTNCardFlowLayout.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
/// 列表视图
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ViewController

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    TGTNCardFlowLayout *layout = [TGTNCardFlowLayout new];
    float itemWidth = ([UIScreen mainScreen].bounds.size.width - 80.0);
    float itemHeight = 100.0;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.sectionInset = UIEdgeInsetsMake(40.0, 40.0, 40.0, 40.0);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.tgtnScaleRatio = 1.0;
    layout.angle = 0.0;
    layout.isChangeCenter = NO;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor cyanColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ViewControllerCollectionCell"];
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.collectionView];
    _collectionView.frame = CGRectMake(0.0, 200.0, [UIScreen mainScreen].bounds.size.width, 180.0);
    
    self.view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1.0];
}

#pragma mark ------ UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ViewControllerCollectionCell" forIndexPath:indexPath];
    
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    UILabel *lable = [[UILabel alloc] initWithFrame:cell.bounds];
    lable.text = @(indexPath.row).stringValue;
    lable.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:lable];
    cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1.0];
    
    return cell;
}
#pragma mark ------ UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld", indexPath.row);
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_collectionView]) {
        UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
        float itemWidth = ([UIScreen mainScreen].bounds.size.width - 80.0);
        float page = itemWidth + collectionViewLayout.minimumLineSpacing;
        
        float index = self.collectionView.contentOffset.x / page;
        
        if (collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            itemWidth = 100.0;
            page = itemWidth + collectionViewLayout.minimumInteritemSpacing;
            
            index = self.collectionView.contentOffset.y / page;
        }
        
//        NSLog(@"index = %f", index);
    }
}


@end
