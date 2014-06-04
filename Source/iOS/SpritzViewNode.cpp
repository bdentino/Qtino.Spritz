#include "SpritzViewNode.h"

SpritzViewNode::SpritzViewNode(QQuickWindow* window)
    : m_id(0),
      m_size(0, 0),
      m_texture(0),
      m_window(window),
      m_image(QImage(":/macbookPro_cropped.png"))
{
    m_texture = m_window->createTextureFromId(0, QSize(1,1));
    setTexture(m_texture);
    setFiltering(QSGTexture::Linear);
}

SpritzViewNode::~SpritzViewNode()
{
    delete m_texture;
}

void SpritzViewNode::newTexture(int id, const QSize &size)
{
    m_mutex.lock();
    m_id = id;
    m_size = size;
    m_mutex.unlock();

    emit pendingNewTexture();
}

void SpritzViewNode::prepareNode()
{
    m_mutex.lock();
    int newId = m_id;
    QSize size = m_size;
    m_id = 0;
    m_mutex.unlock();
    if (newId) {
        delete m_texture;
        m_texture = m_window->createTextureFromId(newId, size,
            QQuickWindow::TextureHasAlphaChannel);
        setTexture(m_texture);

        emit textureInUse();
    }
}

