#ifndef SPRITZVIEWDELEGATE_MM
#define SPRITZVIEWDELEGATE_MM

#include "SpritzViewDelegate.h"
#include "SpritzView.h"

#include <QDebug>

SpritzDelegateHelper::SpritzDelegateHelper(SpritzView* view)
    : QObject(view)
{
    m_view = view;
}

void SpritzDelegateHelper::fireReadingStateChanged()
{
    m_view->readingStateChanged();
}

void SpritzDelegateHelper::firePositionChanged()
{
    m_view->positionChanged();
}

void SpritzDelegateHelper::setError(QString error)
{
    m_view->setError(error);
}

@implementation SpritzDelegate
- (id) initWithSpritzView:(SpritzView*) spritzView
{
    self = [super init];
    if (self) {
        m_spritzView = spritzView;
        m_helper = new SpritzDelegateHelper(spritzView);
    }
    return self;
}

- (void)spritzView:(SPBaseView*)spritzView didStart:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView); Q_UNUSED(charPos); Q_UNUSED(wordPos); Q_UNUSED(timePos); Q_UNUSED(speed);
    m_helper->firePositionChanged();
    m_helper->fireReadingStateChanged();
}

- (void)spritzView:(SPBaseView*)spritzView didReset:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView); Q_UNUSED(charPos); Q_UNUSED(wordPos); Q_UNUSED(timePos); Q_UNUSED(speed);
    m_helper->firePositionChanged();
    m_helper->fireReadingStateChanged();
}

- (void)spritzView:(SPBaseView*)spritzView didPause:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView); Q_UNUSED(charPos); Q_UNUSED(wordPos); Q_UNUSED(timePos); Q_UNUSED(speed);
    m_helper->fireReadingStateChanged();
}

- (void)spritzView:(SPBaseView*)spritzView didResume:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView); Q_UNUSED(charPos); Q_UNUSED(wordPos); Q_UNUSED(timePos); Q_UNUSED(speed);
    m_helper->fireReadingStateChanged();
}

- (void)spritzView:(SPBaseView*)spritzView didSeek:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView); Q_UNUSED(charPos); Q_UNUSED(wordPos); Q_UNUSED(timePos); Q_UNUSED(speed);
    m_helper->firePositionChanged();
}

- (void)spritzView:(SPBaseView*)spritzView didGoBackSentence:(NSInteger)numSentences charPos:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView); Q_UNUSED(charPos); Q_UNUSED(wordPos); Q_UNUSED(timePos); Q_UNUSED(speed); Q_UNUSED(numSentences);
    m_helper->firePositionChanged();
}

- (void)spritzView:(SPBaseView*)spritzView didGoForwaredSentence:(NSInteger)numSentences charPos:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView); Q_UNUSED(charPos); Q_UNUSED(wordPos); Q_UNUSED(timePos); Q_UNUSED(speed); Q_UNUSED(numSentences);
    m_helper->firePositionChanged();
}

- (void)spritzView:(SPBaseView*)spritzView didComplete:(NSInteger)charPos wordPos:(NSInteger)wordPos timePos:(CGFloat)timePos speed:(NSInteger)speed
{
    Q_UNUSED(spritzView); Q_UNUSED(charPos); Q_UNUSED(wordPos); Q_UNUSED(timePos); Q_UNUSED(speed);
    m_helper->firePositionChanged();
    m_helper->fireReadingStateChanged();
}

- (void)spritzView:(SPBaseView*)spritzView didRecieveError:(NSError*)error
{
    Q_UNUSED(spritzView);
    QString errorString = QString::fromNSString([error localizedDescription]);
    qWarning("Spritz View Received Error: '%s'", qPrintable(errorString));
    m_helper->setError(errorString);
}
@end

#endif // SPRITZVIEWDELEGATE_MM
