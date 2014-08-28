#ifndef SPRITZVIEWDELEGATE_H
#define SPRITZVIEWDELEGATE_H

class SpritzView;

#include <UIKit/UIKit.h>
#include <SPViewDelegate.h>

#include <QObject>

class SpritzDelegateHelper : public QObject
{
public:
    SpritzDelegateHelper(SpritzView* view);

    void fireReadingStateChanged();
    void firePositionChanged();
    void setError(QString error);

private:
    SpritzView* m_view;
};

@interface SpritzDelegate : NSObject <SPViewDelegate>
{
    SpritzView* m_spritzView;
    SpritzDelegateHelper* m_helper;
}

-(id) initWithSpritzView:(SpritzView*) spritzView;
@end

#endif // SPRITZVIEWDELEGATE_H
