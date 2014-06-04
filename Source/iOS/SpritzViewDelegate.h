#ifndef SPRITZVIEWDELEGATE_H
#define SPRITZVIEWDELEGATE_H

class SpritzView;

#include <UIKit/UIKit.h>
#include <SPViewDelegate.h>

@interface SpritzDelegate : NSObject <SPViewDelegate>
{
    SpritzView *m_spritzView;
}

-(id) initWithSpritzView:(SpritzView*) spritzView;
@end

#endif // SPRITZVIEWDELEGATE_H
