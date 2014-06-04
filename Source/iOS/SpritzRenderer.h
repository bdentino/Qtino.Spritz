// Modeled after 'LogoRenderer' class in 'TextureInThread' example

#ifndef SPRITZRENDERER_H
#define SPRITZRENDERER_H

#include <QSGNode>
#include <QImage>
#include <QOpenGLShaderProgram>

struct SpritzViewPrivate;
struct SpritzRendererPrivate;
class SpritzRenderer
{
public:
    SpritzRenderer(SpritzViewPrivate* data);
    ~SpritzRenderer();

    void initialize();
    void render();

private:
    void grabSpritzViewPixels();
    quint32 nextHighestPowerOf2(quint32 num);

    QVector<QVector3D> textureVertices;
    QVector<QVector2D> textureCoords;
    QOpenGLShaderProgram program2;
    int vertexAttr2;
    int textureInAttr2;
    int textureUniform2;
    GLubyte* pixelBuffer;
    GLuint textureId;
    quint32 height;
    quint32 width;

    SpritzViewPrivate* m_data;
    SpritzRendererPrivate* m_renderObjects;
};

#endif // SPRITZRENDERER_H
