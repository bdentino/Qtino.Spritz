#include "SpritzRenderThread.h"
#include "SpritzRenderer.h"
#include "SpritzViewPrivate.h"

#include <QOpenGLShaderProgram>
#include <QSGSimpleTextureNode>

SpritzRenderThread::SpritzRenderThread(const QSize& size, SpritzViewPrivate* data)
    : surface(0),
      context(0),
      m_renderFbo(0),
      m_displayFbo(0),
      m_spritzRenderer(0),
      m_size(size),
      m_data(data)
{
}

void SpritzRenderThread::renderNext()
{
    context->makeCurrent(surface);

    if (!m_renderFbo)
    {
        //Initialize the buffers and renderer
        QOpenGLFramebufferObjectFormat format;
        format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
        m_renderFbo = new QOpenGLFramebufferObject(m_size, format);
        m_displayFbo = new QOpenGLFramebufferObject(m_size, format);
        m_spritzRenderer = new SpritzRenderer(m_data);
        m_spritzRenderer->initialize();
    }

    m_renderFbo->bind();
    glViewport(0, 0, m_size.width(), m_size.height());

    m_spritzRenderer->render();

    glFlush();

    m_renderFbo->bindDefault();
    qSwap(m_renderFbo, m_displayFbo);

    emit textureReady(m_displayFbo->texture(), m_size);
}

void SpritzRenderThread::shutdown()
{
    context->makeCurrent(surface);
    delete m_renderFbo;
    delete m_displayFbo;
    delete m_spritzRenderer;
    context->doneCurrent();
    delete context;

    // schedule this to be deleted only after we're done cleaning up
    surface->deleteLater();

    // Stop event processing, move the thread to GUI and make sure it is deleted.
    exit();
    moveToThread(QGuiApplication::instance()->thread());
}
