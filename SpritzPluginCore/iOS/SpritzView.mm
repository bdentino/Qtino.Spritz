#include <UIKit/UIKit.h>
#include <SPBaseView.h>
#include <SPPlainTextSource.h>
#include <SPURLSource.h>

#include <QtGui>
#include <QtQuick>
#include <QtGui/5.3.1/QtGui/qpa/qplatformnativeinterface.h>

#include "SpritzView.h"
#include "SpritzRenderThread.h"
#include "SpritzViewDelegate.h"
#include "SpritzViewNode.h"
#include "SpritzViewPrivate.h"

#include <QDebug>

//QList<QThread*> SpritzView::s_threads;

SpritzView::SpritzView()
    : m_error(""),
      m_data(NULL)
//      m_renderThread(NULL),
//      m_node(NULL)
{
    setFlag(ItemHasContents, true);

    m_data = new SpritzViewPrivate;
    m_data->delegate = [[SpritzDelegate alloc] initWithSpritzView: this];
    m_data->view = NULL;

    m_progressNotifier.setSingleShot(false);
    m_progressNotifier.setInterval(100);
    connect(&m_progressNotifier, SIGNAL(timeout()), this, SIGNAL(progressChanged()));
    connect(this, SIGNAL(positionChanged()), this, SIGNAL(progressChanged()));

    if (window() && window()->openglContext())
        initSpritzComponent();
    else if (window())
        connect(window(), SIGNAL(sceneGraphInitialized()), this, SLOT(initSpritzComponent()));
    else
        connect(this, SIGNAL(windowChanged(QQuickWindow*)), this, SLOT(onWindowChanged(QQuickWindow*)));

    onParentChange();
    connect(this, SIGNAL(readingStateChanged()), this, SLOT(onGeometryChanged()));

    //m_renderThread = new SpritzRenderThread(m_data);
    //SpritzView::s_threads << m_renderThread;
    //connect(this, SIGNAL(readingStateChanged()), this, SLOT(resetRenderer()));
    //connect(this, SIGNAL(positionChanged()), this, SLOT(resetRenderer()));

    //connect(this, SIGNAL(textColorChanged()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);
    //connect(this, SIGNAL(focusColorChanged()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);
    //connect(this, SIGNAL(initialized()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);
}

SpritzView::~SpritzView()
{
//    if (m_renderThread)
//        m_renderThread->deleteLater();
    delete m_data;
}

int SpritzView::wordsPerMinute()
{
    return m_data->view.speed;
}

int SpritzView::currentSegmentIndex()
{
    return m_data->view.segmentPosition;
}

int SpritzView::characterIndex()
{
    return m_data->view.characterPosition;
}

int SpritzView::timeIndexMs()
{
    return m_data->view.timePosition;
}

double SpritzView::progress()
{
    return m_data->view.progress;
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
    qDebug() << "Setting WPM: " << wpm;
    if (wpm == wordsPerMinute()) return;
    m_data->view.speed = wpm;
    emit wordsPerMinuteChanged();
}

void SpritzView::jumpToCharacter(int index)
{
    [m_data->view seekToCharacter:index absolute:YES];
}

//TODO: Actually implement color changing when Spritz makes it available
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

void SpritzView::load(QString content)
{
    NSString* iosString = content.toNSString();
    [m_data->view load:[SPPlainTextSource plainTextSourceWithText: iosString]];
}

void SpritzView::load(QUrl url)
{
    NSString* iosUrl = url.toString().toNSString();
    [m_data->view load:[SPURLSource urlSourceWithString: iosUrl]];
}

void SpritzView::spritzText(QString content, int charIndex)
{
    NSString* iosString = content.toNSString();
    [m_data->view start:[SPPlainTextSource plainTextSourceWithText: iosString]
                         speed: wordsPerMinute()
                         characterPosition: charIndex == -1 ? characterIndex() : charIndex];
    m_progressNotifier.start();
}

void SpritzView::spritzUrl(QUrl url)
{
    NSString* iosUrl = url.toString().toNSString();
    [m_data->view start:[SPURLSource urlSourceWithString: iosUrl]
                         speed: wordsPerMinute() ];
    m_progressNotifier.start();
}

void SpritzView::pause()
{
    [m_data->view pause];
    m_progressNotifier.stop();
}

void SpritzView::resume()
{
    [m_data->view resume];
    m_progressNotifier.start();
}

void SpritzView::reset()
{
    [m_data->view reset];
    m_progressNotifier.stop();
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

void SpritzView::goBackSegments(int numSegments)
{
    [m_data->view seekToSegment:(-numSegments) absolute:NO];
}

void SpritzView::goForwardSegments(int numSegments)
{
    [m_data->view seekToSegment:numSegments absolute:NO];
}

void SpritzView::setError(QString error)
{
    m_error = error;
    emit errorChanged();
}

void SpritzView::componentComplete()
{
    QQuickItem::componentComplete();
    if (width() != 0 && height() != 0)
    {
        initSpritzComponent();
    }
}

void logViewHierarchy(UIView* view)
{
    NSLog(@"%@", view);
    for (UIView* subview in view.subviews)
    {
        logViewHierarchy(subview);
    }
}

void SpritzView::onWindowChanged(QQuickWindow* window)
{
    if (window == NULL) return;
    if (window->openglContext())
        initSpritzComponent();
    else
        connect(window, SIGNAL(sceneGraphInitialized()), this, SLOT(initSpritzComponent()));
}

void SpritzView::initSpritzComponent()
{
    qDebug() << "Initializing SpritzView";
    QTime timer; timer.start();
    float width = boundingRect().width();
    float height = boundingRect().height();
    //    float scale = [[UIScreen mainScreen] scale];
    m_data->view = [[SPBaseView alloc] initWithFrame: CGRectMake(0, 0, width, height)];
    qDebug() << "Took" << timer.elapsed() << "ms to init/alloc SPBaseView";

    [m_data->view setDelegate:id(m_data->delegate)];

    UIView* textView = [m_data->view.subviews objectAtIndex:0];
    CGRect frame = textView.frame;
    frame.size.width = width;
    frame.size.height = height;
    textView.frame = frame;
    qDebug() << "Took" << timer.elapsed() << "ms to setup textView frame";

    //logViewHierarchy(m_data->view);

    [textView setBackgroundColor:[UIColor colorWithWhite:1 alpha: 0.0]];
    [[textView layer] setCornerRadius: 10];
    [[textView layer] setMasksToBounds: true];
    textView.alpha = this->opacity();
    qDebug() << "Took" << timer.elapsed() << "ms to setup textView appearance";

    [[m_data->view.subviews objectAtIndex: 1] setHidden: true];
    [[m_data->view.subviews objectAtIndex: 2] setHidden: true];
    qDebug() << "Took" << timer.elapsed() << "ms to setup rest of view";
    emit initialized();
    qDebug() << "Took" << timer.elapsed() << "ms to initialize";
}

void SpritzView::geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry)
{
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
    onGeometryChanged();
}

void SpritzView::onParentChange()
{
    foreach (QQuickItem* parent, m_visualParents) {
        parent->disconnect(this, SLOT(onGeometryChanged()));
        parent->disconnect(this, SLOT(onParentChange()));
    }
    m_visualParents.clear();

    QQuickItem* parent = this;
    do {
        m_visualParents.append(parent);
        connect(parent, SIGNAL(heightChanged()), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(opacityChanged()), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(rotationChanged()), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(scaleChanged()), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(transformOriginChanged(TransformOrigin)), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(visibleChanged()), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(widthChanged()), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(xChanged()), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(yChanged()), this, SLOT(onGeometryChanged()));
        connect(parent, SIGNAL(parentChanged(QQuickItem*)), this, SLOT(onParentChange()));
        parent = parent->parentItem();
    } while (parent != NULL);
}

void SpritzView::onGeometryChanged()
{
    qreal originX;
    qreal originY;
    switch (this->transformOrigin()) {
    case QQuickItem::TopLeft:
        originX = 0; originY = 0;
        break;
    case QQuickItem::Top:
        originX = this->width() / 2; originY = 0;
        break;
    case QQuickItem::TopRight:
        originX = this->width(); originY = 0;
        break;
    case QQuickItem::Left:
        originX = 0; originY = this->height() / 2;
        break;
    case QQuickItem::Center:
        originX = this->width() / 2; originY = this->height() / 2;
        break;
    case QQuickItem::Right:
        originX = this->width(); originY = this->height() / 2;
        break;
    case QQuickItem::BottomLeft:
        originX = 0; originY = this->height();
        break;
    case QQuickItem::Bottom:
        originX = this->width() / 2; originY = this->height();
        break;
    case QQuickItem::BottomRight:
        originX = this->width(); originY = this->height();
        break;
    }

    QPointF point = this->mapToScene(QPointF(0, 0));

    UIView* textView = [m_data->view.subviews objectAtIndex:0];

    bool visible = true;
    qreal opacity = 1;
    QQuickItem* parent = this;
    do {
        opacity *= parent->opacity();
        visible = parent->isVisible();
        parent = parent->parentItem();
    } while (parent && visible);

    textView.alpha = opacity;

    if (!visible || opacity == 0) {
        // Get the UIView that backs our QQuickWindow:
        UIView *view = static_cast<UIView *>(
                    QGuiApplication::platformNativeInterface()
                    ->nativeResourceForWindow("uiview", window()));
        if ([m_data->view isDescendantOfView: view]) {
            qDebug() << "Hiding textview";
            [m_data->view removeFromSuperview];
        }
    }
    else {
        // Get the UIView that backs our QQuickWindow:
        UIView *view = static_cast<UIView *>(
                    QGuiApplication::platformNativeInterface()
                    ->nativeResourceForWindow("uiview", window()));
        if (![m_data->view isDescendantOfView: view]) {
            qDebug() << "Unhiding textview";
            [view addSubview: m_data->view];
        }
    }

    CGRect viewFrame = m_data->view.frame;
    viewFrame.origin.x = point.x();
    viewFrame.origin.y = point.y();
    viewFrame.size.width = this->width();
    viewFrame.size.height = this->height();
    m_data->view.frame = viewFrame;

    [m_data->view setNeedsDisplay];
}

//void SpritzView::readyToRender()
//{
//    if (!m_data->view)
//        initSpritzComponent();
//    m_renderThread->surface = new QOffscreenSurface();
//    m_renderThread->surface->setFormat(m_renderThread->context->format());
//    m_renderThread->surface->create();

//    m_renderThread->moveToThread(m_renderThread);

//    connect(window(), SIGNAL(sceneGraphInvalidated()), m_renderThread,
//            SLOT(shutdown()), Qt::QueuedConnection);

//    m_renderThread->start();
//    update();
//}

//QSGNode* SpritzView::updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData)
//{
//    Q_UNUSED(updatePaintNodeData);
//    m_node = static_cast<SpritzViewNode*>(oldNode);

//    if (!m_renderThread->context)
//    {
//        QOpenGLContext* current = window()->openglContext();
//        current->doneCurrent();
//        m_renderThread->context = new QOpenGLContext();
//        m_renderThread->context->setFormat(current->format());
//        m_renderThread->context->setShareContext(current);
//        m_renderThread->context->create();
//        m_renderThread->context->moveToThread(m_renderThread);

//        current->makeCurrent(window());

//        QMetaObject::invokeMethod(this, "readyToRender");
//        return 0;
//    }

//    if (!m_node) {
//        m_node = new SpritzViewNode(window());

//        connect(m_renderThread, SIGNAL(textureReady(int,QSize)),
//                m_node, SLOT(newTexture(int,QSize)), Qt::DirectConnection);
//        resetRenderer();
//    }
//    m_node->setRect(boundingRect());

//    return m_node;
//}

//void SpritzView::resetRenderer()
//{
//    qDebug() << "Reading Content:" << QString::fromNSString(m_data->view.text);
//    if (!m_node) return;
//    if (loading() || (started() && !paused()))
//    {
//        connect(m_node, SIGNAL(pendingNewTexture()), window(), SLOT(update()), Qt::QueuedConnection);
//        connect(window(), SIGNAL(beforeRendering()), m_node, SLOT(prepareNode()), Qt::DirectConnection);
//        connect(m_node, SIGNAL(textureInUse()), m_renderThread, SLOT(renderNext()), Qt::QueuedConnection);

//        QMetaObject::invokeMethod(m_renderThread, "renderNext", Qt::QueuedConnection);
//    }
//    else
//    {
//        disconnect(m_node, SIGNAL(pendingNewTexture()), window(), SLOT(update()));
//        disconnect(window(), SIGNAL(beforeRendering()), m_node, SLOT(prepareNode()));
//        disconnect(m_node, SIGNAL(textureInUse()), m_renderThread, SLOT(renderNext()));
//    }
//}
