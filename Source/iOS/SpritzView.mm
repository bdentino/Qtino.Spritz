#include <UIKit/UIKit.h>
#include <SPBaseView.h>

#include <QtGui>
#include <QtQuick>
#include <QtGui/5.3.0/QtGui/qpa/qplatformnativeinterface.h>

#include "SpritzView.h"
#include "SpritzRenderThread.h"
#include "SpritzViewDelegate.h"
#include "SpritzViewNode.h"
#include "SpritzViewPrivate.h"

//TODO: Don't think I really need this list...
QList<QThread*> SpritzView::s_threads;

SpritzView::SpritzView()
    : m_error(""),
      m_renderThread(NULL),
      m_data(NULL),
      m_node(NULL)
{
    setFlag(ItemHasContents, true);

    m_data = new SpritzViewPrivate;
    m_data->delegate = [[SpritzDelegate alloc] initWithSpritzView: this];
    m_data->view = NULL;

    m_renderThread = new SpritzRenderThread(m_data);
    SpritzView::s_threads << m_renderThread;

    connect(this, SIGNAL(readingStateChanged()), this, SLOT(resetRenderer()));
    connect(this, SIGNAL(positionChanged()), this, SLOT(resetRenderer()));

    connect(this, SIGNAL(textColorChanged()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);
    connect(this, SIGNAL(focusColorChanged()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);
    connect(this, SIGNAL(initialized()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);

}

SpritzView::~SpritzView()
{
    m_renderThread->deleteLater();
    delete m_data;
}

int SpritzView::wordsPerMinute()
{
    return m_data->view.speed;
}

int SpritzView::currentWordIndex()
{
    return m_data->view.wordPosition;
}

int SpritzView::characterIndex()
{
    return m_data->view.characterPosition;
}

int SpritzView::timeIndexMs()
{
    return m_data->view.timePosition;
}

bool SpritzView::loading()
{
    return m_data->view.loading;
}

bool SpritzView::started()
{
    return m_data->view.started;
}

bool SpritzView::paused()
{
    return m_data->view.paused;
}

QString SpritzView::error()
{
    return m_error;
}

QColor SpritzView::textColor()
{
    return m_textColor;
}

QColor SpritzView::focusColor()
{
    return m_focusColor;
}

void SpritzView::setWordsPerMinute(int wpm)
{
    if (wpm == wordsPerMinute()) return;
    m_data->view.speed = wpm;
    emit wordsPerMinuteChanged();
}

void SpritzView::jumpToWord(int index)
{
    if (index == currentWordIndex()) return;
    [m_data->view seek:index absolute:YES];
    //TODO: Delegate to emit signals when things change
}

//TODO: Actually implement color changing in renderer
void SpritzView::setTextColor(QColor color)
{
    if (m_textColor == color) return;
    m_textColor = color;
    emit textColorChanged();
}

void SpritzView::setFocusColor(QColor color)
{
    if (m_focusColor == color) return;
    m_focusColor = color;
    emit focusColorChanged();
}

void SpritzView::spritzText(QString content)
{
    NSString* iosString = content.toNSString();
    [m_data->view start:iosString sourceType:SPSourceFlagPlainText];
}

void SpritzView::spritzUrl(QUrl url)
{
    NSString* iosUrl = url.toString().toNSString();
    [m_data->view start:iosUrl sourceType:SPSourceFlagURL];
}

void SpritzView::pause()
{
    [m_data->view pause];
}

void SpritzView::resume()
{
    [m_data->view resume];
}

void SpritzView::reset()
{
    [m_data->view reset];
}

void SpritzView::goBackSentence()
{
    [m_data->view goBackSentence];
}

void SpritzView::goForwardSentence()
{
    [m_data->view goForwardSentence];
}

void SpritzView::goBackSentences(int numSentences)
{
    [m_data->view goBackSentences:numSentences];
}

void SpritzView::goForwardSentences(int numSentences)
{
    [m_data->view goForwardSentences:numSentences];
}

void SpritzView::goBackWords(int numWords)
{
    [m_data->view seek:(-numWords) absolute:NO];
}

void SpritzView::goForwardWords(int numWords)
{
    [m_data->view seek:numWords absolute:NO];
}

void SpritzView::componentComplete()
{
    QQuickItem::componentComplete();
    if (width() != 0 && height() != 0)
    {
        initSpritzComponent();
    }
}

void SpritzView::initSpritzComponent()
{
    float width = boundingRect().width();
    float height = boundingRect().height();
    float scale = [[UIScreen mainScreen] scale];
    m_data->view = [[SPBaseView alloc] initWithFrame: CGRectMake(0, 0, width * scale, height * scale)];
    [m_data->view setDelegate:id(m_data->delegate)];

    UIView* textView = [m_data->view.subviews objectAtIndex:0];
    [textView setBackgroundColor:[UIColor colorWithWhite:1 alpha: 0.1]];
    [[textView layer] setCornerRadius: 10];
    [[textView layer] setMasksToBounds: true];

    [[m_data->view.subviews objectAtIndex: 1] setHidden: true];
    emit initialized();
}

void SpritzView::readyToRender()
{
    if (!m_data->view)
        initSpritzComponent();
    m_renderThread->surface = new QOffscreenSurface();
    m_renderThread->surface->setFormat(m_renderThread->context->format());
    m_renderThread->surface->create();

    m_renderThread->moveToThread(m_renderThread);

    connect(window(), SIGNAL(sceneGraphInvalidated()), m_renderThread,
            SLOT(shutdown()), Qt::QueuedConnection);

    m_renderThread->start();
    update();
}

QSGNode* SpritzView::updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData)
{
    Q_UNUSED(updatePaintNodeData);
    m_node = static_cast<SpritzViewNode*>(oldNode);

    if (!m_renderThread->context)
    {
        QOpenGLContext* current = window()->openglContext();
        current->doneCurrent();
        m_renderThread->context = new QOpenGLContext();
        m_renderThread->context->setFormat(current->format());
        m_renderThread->context->setShareContext(current);
        m_renderThread->context->create();
        m_renderThread->context->moveToThread(m_renderThread);

        current->makeCurrent(window());

        QMetaObject::invokeMethod(this, "readyToRender");
        return 0;
    }

    if (!m_node) {
        m_node = new SpritzViewNode(window());

        connect(m_renderThread, SIGNAL(textureReady(int,QSize)),
                m_node, SLOT(newTexture(int,QSize)), Qt::DirectConnection);
        resetRenderer();
    }
    m_node->setRect(boundingRect());

    return m_node;
}

void SpritzView::resetRenderer()
{
    if (!m_node) return;
    if (loading() || (started() && !paused()))
    {
        connect(m_node, SIGNAL(pendingNewTexture()), window(), SLOT(update()), Qt::QueuedConnection);
        connect(window(), SIGNAL(beforeRendering()), m_node, SLOT(prepareNode()), Qt::DirectConnection);
        connect(m_node, SIGNAL(textureInUse()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);

        QMetaObject::invokeMethod(m_renderThread, "renderNext", Qt::QueuedConnection);
    }
    else
    {
        disconnect(m_node, SIGNAL(pendingNewTexture()), window(), SLOT(update()));
        disconnect(window(), SIGNAL(beforeRendering()), m_node, SLOT(prepareNode()));
        disconnect(m_node, SIGNAL(textureInUse()), m_renderThread, SLOT(renderNext()));
    }
}

void SpritzView::setError(QString error)
{
    m_error = error;
    emit errorChanged();
}
