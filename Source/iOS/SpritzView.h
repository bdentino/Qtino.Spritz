#ifndef SPRITZVIEW_H
#define SPRITZVIEW_H

#include <QQuickItem>
#include <QtQuick/QQuickFramebufferObject>

struct SpritzViewPrivate;
class SpritzRenderThread;
class SpritzViewNode;
class SpritzView : public QQuickItem
{
    friend class SpritzDelegateHelper;

    Q_OBJECT

    //TODO: Should i allow setting API keys through this class? (SpritzSDK attached property)

    Q_PROPERTY(int wordsPerMinute READ wordsPerMinute WRITE setWordsPerMinute NOTIFY wordsPerMinuteChanged)
    Q_PROPERTY(int currentWordIndex READ currentWordIndex WRITE jumpToWord NOTIFY positionChanged)
    Q_PROPERTY(int characterIndex READ characterIndex)
    Q_PROPERTY(int timeIndexMs READ timeIndexMs NOTIFY positionChanged)

    Q_PROPERTY(bool loading READ loading NOTIFY readingStateChanged)
    Q_PROPERTY(bool started READ started NOTIFY readingStateChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY readingStateChanged)

    Q_PROPERTY(QString error READ error NOTIFY errorChanged)

    //TODO: Implement color changing
    Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor NOTIFY textColorChanged)
    Q_PROPERTY(QColor focusColor READ focusColor WRITE setFocusColor NOTIFY focusColorChanged)

public:
    SpritzView();
    ~SpritzView();

    int wordsPerMinute();
    int currentWordIndex();
    int characterIndex();
    int timeIndexMs();

    bool loading();
    bool started();
    bool paused();

    QColor textColor();
    QColor focusColor();

    void setWordsPerMinute(int wpm);

    void setTextColor(QColor color);
    void setFocusColor(QColor color);

    QString error();

signals:
    void initialized();
    void wordsPerMinuteChanged();
    void errorChanged();

    void readingStateChanged();
    void positionChanged();

    void textColorChanged();
    void focusColorChanged();

    void started(int charIndex, int wordIndex, int timeIndexMs, int wpm);
    void reset(int charIndex, int wordIndex, int timeIndexMs, int wpm);
    void paused(int charIndex, int wordIndex, int timeIndexMs, int wpm);
    void resumed(int charIndex, int wordIndex, int timeIndexMs, int wpm);
    void seek(int charIndex, int wordIndex, int timeIndexMs, int wpm);
    void movedBackSentence(int numSentences, int charIndex, int wordIndex, int timeIndexMs, int wpm);
    void movedForwardSentence(int numSentences, int charIndex, int wordIndex, int timeIndexMs, int wpm);
    void finished(int charIndex, int wordIndex, int timeIndexMs, int wpm);

public slots:
    void spritzText(QString content);
    void spritzUrl(QUrl url);
    void pause();
    void resume();
    void reset();

    void goBackSentence();
    void goForwardSentence();

    void goBackSentences(int numSentences);
    void goForwardSentences(int numSentences);
    void goBackWords(int numWords);
    void goForwardWords(int numWords);

    void jumpToWord(int index);

protected slots:
    void componentComplete();
    void readyToRender();
    void resetRenderer();

protected:
    QSGNode* updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData);
    void setError(QString error);

private:
    void initSpritzComponent();

    QColor m_textColor;
    QColor m_focusColor;

    QString m_error;

    SpritzRenderThread* m_renderThread;
    SpritzViewPrivate* m_data;
    SpritzViewNode* m_node;

    static QList<QThread*> s_threads;
};

#endif // SPRITZVIEW_H
