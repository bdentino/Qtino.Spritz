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
    : m_renderThread(0),
      m_data(0)
{
    Q_INIT_RESOURCE(images);
    setFlag(ItemHasContents, true);

    m_data = new SpritzViewPrivate;
    initSpritzComponent();

    m_renderThread = new SpritzRenderThread(QSize(512, 512), m_data);
    SpritzView::s_threads << m_renderThread;
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

void SpritzView::onHeightChanged()
{

}

void SpritzView::onWidthChanged()
{

}

void SpritzView::onXChanged()
{

}

void SpritzView::onYChanged()
{

}

void SpritzView::onCompleted()
{

}

void SpritzView::initSpritzComponent()
{
    m_data->delegate = [[SpritzDelegate alloc] initWithSpritzView: this];
    m_data->view = NULL;

    //TODO: Make this dependent on the actual size
    m_data->view = [[SPBaseView alloc] initWithFrame: CGRectMake(0, 0, 600, 200)];
    [m_data->view setDelegate:id(m_data->delegate)];

    UIView* textView = [m_data->view.subviews objectAtIndex:0];
    [textView setBackgroundColor:[UIColor colorWithWhite:1 alpha: 0.1]];
    [[textView layer] setCornerRadius: 10];
    [[textView layer] setMasksToBounds: true];

    [[m_data->view.subviews objectAtIndex: 1] setHidden: true];
}

void SpritzView::readyToRender()
{
    m_renderThread->surface = new QOffscreenSurface();
    m_renderThread->surface->setFormat(m_renderThread->context->format());
    m_renderThread->surface->create();

    m_renderThread->moveToThread(m_renderThread);

    connect(window(), SIGNAL(sceneGraphInvalidated()), m_renderThread, SLOT(shutdown()), Qt::QueuedConnection);

    m_renderThread->start();
    update();
}

QSGNode* SpritzView::updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData)
{
    qDebug() << "Updating Paint Node";
    Q_UNUSED(updatePaintNodeData);
    SpritzViewNode *node = static_cast<SpritzViewNode*>(oldNode);

    if (!m_renderThread->context) {
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

    if (!node) {
        node = new SpritzViewNode(window());

        connect(m_renderThread, SIGNAL(textureReady(int,QSize)), node, SLOT(newTexture(int,QSize)), Qt::DirectConnection);
        connect(node, SIGNAL(pendingNewTexture()), window(), SLOT(update()), Qt::QueuedConnection);
        connect(window(), SIGNAL(beforeRendering()), node, SLOT(prepareNode()), Qt::DirectConnection);
        connect(node, SIGNAL(textureInUse()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);

        QMetaObject::invokeMethod(m_renderThread, "renderNext", Qt::QueuedConnection);
    }

    node->setRect(boundingRect());

    return node;
}
