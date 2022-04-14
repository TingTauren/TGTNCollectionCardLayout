//
//  TGTNCardFlowLayout.m
//  TGTNCollectionCardLayout
//
//  Created by Mac on 2022/4/12.
//

#import "TGTNCardFlowLayout.h"

@interface TGTNCardFlowLayout()
/// 滚动偏移
@property (nonatomic, assign) float contentOffset;
/// 视图长度
@property (nonatomic, assign) float viewLength;
/// 列表长度
@property (nonatomic, assign) float itemLength;
@end

@implementation TGTNCardFlowLayout

#pragma mark ------ get
- (float)contentOffset {
    float contentOffset = self.collectionView.contentOffset.x;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) { // 垂直
        contentOffset = self.collectionView.contentOffset.y;
    }
    return contentOffset;
}
- (float)viewLength {
    float length = self.collectionView.frame.size.width;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) { // 垂直
        length = self.collectionView.frame.size.height;
    }
    return length;
}
- (float)itemLength {
    float length = self.itemSize.width + self.minimumLineSpacing;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) { // 垂直
        length = self.itemSize.height + self.minimumInteritemSpacing;
    }
    return length;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 缩放比例 (0.0 - 1.0)
        self.tgtnScaleRatio = 0.8;
        // 旋转角度 (0 - M_PI)
        self.angle = M_PI_4 / 10.0;
        // 是否变化center值
        self.isChangeCenter = YES;
        
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return self;
}

#pragma mark ------ system
/// 初始化 生成每个视图的布局信息
- (void)prepareLayout {
    [super prepareLayout];
}
/// 决定一段区域所有cell和头尾视图的布局属性
- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *originalArray = [super layoutAttributesForElementsInRect:rect];
    NSArray *curArray = [[NSArray alloc] initWithArray:originalArray copyItems:YES];
    // 计算collectionView中心点的y值(这个中心点可不是屏幕的中线点哦，是整个collectionView的，所以是包含在屏幕之外的偏移量的哦)
    CGFloat centerPoint = self.contentOffset + self.viewLength * 0.5;
    
    // 拿到每一个cell的布局属性，在原有布局属性的基础上，进行调整
    for (UICollectionViewLayoutAttributes *attrs in curArray) {
        float attrsCenterPoint = attrs.center.x;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) { // 垂直
            attrsCenterPoint = attrs.center.y;
        }
        // cell的中心点 和 collectionView最中心点 间距的绝对值
        float movingDistance = attrsCenterPoint - centerPoint;
        
        // 移动的距离和屏幕宽度的的比例
        float scalingRatio = fabsf(movingDistance) / self.itemLength;
        // 比例缩放大小
        scalingRatio = scalingRatio * (1.0 - self.tgtnScaleRatio);
        scalingRatio = 1 - scalingRatio;
        
        // 旋转比例 移动距离 和 大小 比
        float rotationScale = movingDistance / self.itemLength;
        // 旋转角度
        float angle = rotationScale * self.angle;
        
        // 中心偏移值 (不知道算法对不对 - 大佬给个建议)
        float addCenterValue = fabsf(angle) * (self.itemLength * 0.5);
        
        // 设置缩放比例
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) { // 垂直
            attrs.transform = CGAffineTransformMakeScale(scalingRatio, 1.0);
            // 0 - M_PI 旋转角度是0-180
            attrs.transform = CGAffineTransformRotate(attrs.transform, angle);
            if (self.isChangeCenter) {
                // 中心点偏移
                attrs.center = CGPointMake(attrs.center.x - addCenterValue, attrs.center.y);
            }
        } else {
            attrs.transform = CGAffineTransformMakeScale(1.0, scalingRatio);
            // 0 - M_PI 旋转角度是0-180
            attrs.transform = CGAffineTransformRotate(attrs.transform, angle);
            if (self.isChangeCenter) {
                // 中心点偏移
                attrs.center = CGPointMake(attrs.center.x, attrs.center.y + addCenterValue);
            }
        }
    }
    
    return curArray;
}
/// 返回indexPath位置cell对应的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}
/// 返回indexPath位置头和脚视图对应的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
}
/// 返回内容高度
- (CGSize)collectionViewContentSize {
    return [super collectionViewContentSize];
}
/// 是否重新计算
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect) newBounds {
    return YES;
}
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint) proposedContentOffset withScrollingVelocity:(CGPoint) velocity {
    float velocityPoint = velocity.x;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) { // 垂直
        velocityPoint = velocity.y;
    }
    
    CGFloat rawPageValue = self.contentOffset / self.itemLength;
    CGFloat currentPage = (velocityPoint > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocityPoint > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocityPoint) > [self _tgtnFlickVelocity];
    if (pannedLessThanAPage && flicked) {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) { // 垂直
            proposedContentOffset.y = nextPage * self.itemLength;
        } else {
            proposedContentOffset.x = nextPage * self.itemLength;
        }
    } else {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) { // 垂直
            proposedContentOffset.y = round(rawPageValue) * self.itemLength;
        } else {
            proposedContentOffset.x = round(rawPageValue) * self.itemLength;
        }
    }
    return proposedContentOffset;
}

#pragma mark ------ Private
- (CGFloat)_tgtnFlickVelocity {
    return 0.01;
}

@end
