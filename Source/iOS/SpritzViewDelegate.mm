#ifndef SPRITZVIEWDELEGATE_MM
#define SPRITZVIEWDELEGATE_MM

#include "SpritzViewDelegate.h"

#include <QDebug>

@implementation SpritzDelegate
- (id) initWithSpritzView:(SpritzView*) spritzView
{
    self = [super init];
    if (self) {
        m_spritzView = spritzView;
    }
    return self;
}

- (void)spritzView:(SPBaseView*)spritzView didStart:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView);
    Q_UNUSED(charPos);
    Q_UNUSED(wordPos);
    Q_UNUSED(timePos);
    Q_UNUSED(speed);
    qDebug("SpritzView DidStart");
}

- (void)spritzView:(SPBaseView*)spritzView didReset:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView);
    Q_UNUSED(charPos);
    Q_UNUSED(wordPos);
    Q_UNUSED(timePos);
    Q_UNUSED(speed);
    qDebug("SpritzView DidReset");
}

- (void)spritzView:(SPBaseView*)spritzView didPause:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView);
    Q_UNUSED(charPos);
    Q_UNUSED(wordPos);
    Q_UNUSED(timePos);
    Q_UNUSED(speed);
    qDebug("SpritzView DidPause");
}

- (void)spritzView:(SPBaseView*)spritzView didResume:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView);
    Q_UNUSED(charPos);
    Q_UNUSED(wordPos);
    Q_UNUSED(timePos);
    Q_UNUSED(speed);
    qDebug("SpritzView DidResume");
}

- (void)spritzView:(SPBaseView*)spritzView didSeek:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView);
    Q_UNUSED(charPos);
    Q_UNUSED(wordPos);
    Q_UNUSED(timePos);
    Q_UNUSED(speed);
    qDebug("SpritzView DidSeek");
}

- (void)spritzView:(SPBaseView*)spritzView didGoBackSentence:(NSInteger)numSentences charPos:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView);
    Q_UNUSED(charPos);
    Q_UNUSED(wordPos);
    Q_UNUSED(timePos);
    Q_UNUSED(speed);
    Q_UNUSED(numSentences);
    qDebug("SpritzView DidGoBackSentence");
}

- (void)spritzView:(SPBaseView*)spritzView didGoForwaredSentence:(NSInteger)numSentences charPos:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView);
    Q_UNUSED(charPos);
    Q_UNUSED(wordPos);
    Q_UNUSED(timePos);
    Q_UNUSED(speed);
    Q_UNUSED(numSentences);
    qDebug("SpritzView DidGoForwaredSentence");
}

- (void)spritzView:(SPBaseView*)spritzView didComplete:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView);
    Q_UNUSED(charPos);
    Q_UNUSED(wordPos);
    Q_UNUSED(timePos);
    Q_UNUSED(speed);
    qDebug("SpritzView DidComplete");
}

- (void)spritzView:(SPBaseView*)spritzView didRecieveError:(NSError*)error
{
    Q_UNUSED(spritzView);
    Q_UNUSED(error);
    qDebug("SpritzView DidReceiveError");
}
@end

#endif // SPRITZVIEWDELEGATE_MM
