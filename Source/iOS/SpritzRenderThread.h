// Modeled after RenderThread class in 'TextureInThread' example

#ifndef SPRITZRENDERTHREAD_H
#define SPRITZRENDERTHREAD_H

#include <QThread>
#include <QtGui>

struct SpritzViewPrivate;
class QOpenGLShaderProgram;
class SpritzRenderer;
class SpritzRenderThread : public QThread
{
    Q_OBJECT

public:
    SpritzRenderThread(const QSize& size, SpritzViewPrivate* data);

    QOffscreenSurface* surface;
    QOpenGLContext* context;

public slots:
    void renderNext();
    void shutdown();

signals:
    void textureReady(int id, const QSize &size);

private:
    QOpenGLFramebufferObject* m_renderFbo;
    QOpenGLFramebufferObject* m_displayFbo;

    SpritzRenderer* m_spritzRenderer;
    QSize m_size;
    SpritzViewPrivate* m_data;
};

#endif // SPRITZRENDERTHREAD_H
