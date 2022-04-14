//
//  TGTNCardFlowLayout.h
//  TGTNCollectionCardLayout
//
//  Created by Mac on 2022/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TGTNCardFlowLayout : UICollectionViewFlowLayout

/// 缩放比例 (0.0 - 1.0)
@property (nonatomic, assign) float tgtnScaleRatio;

/// 旋转角度 (0 - M_PI)
@property (nonatomic, assign) float angle;
/// 是否变化center值
@property (nonatomic, assign) BOOL isChangeCenter;

@end

NS_ASSUME_NONNULL_END
