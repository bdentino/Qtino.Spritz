#include <UIKit/UIKit.h>
#include <SPBaseView.h>

#include "SpritzRenderer.h"
#include "SpritzViewPrivate.h"

#include <QPainter>
#include <QPaintEngine>
#include <math.h>
#include <QFile>
#include <QUrl>

struct SpritzRendererPrivate {
    CGColorSpaceRef colorSpace;
    CGContextRef context;
};

SpritzRenderer::SpritzRenderer(SpritzViewPrivate* data)
    : m_data(data),
      m_renderObjects(new SpritzRendererPrivate)
{
}

SpritzRenderer::~SpritzRenderer()
{
    CGColorSpaceRelease(m_renderObjects->colorSpace);
    CGContextRelease(m_renderObjects->context);
    free(pixelBuffer);
}

void SpritzRenderer::initialize()
{
    QOpenGLShader *vshader2 = new QOpenGLShader(QOpenGLShader::Vertex, &program2);
    const char *vsrc2 =
        "attribute vec4 position;           \n"
        "attribute vec2 textureXYin;        \n"
        "varying vec2 textureXYout;         \n"
        "void main(void)                    \n"
        "{                                  \n"
        "   gl_Position = position;         \n"
        "   textureXYout = textureXYin;     \n"
        "}                                  \n";

    vshader2->compileSourceCode(vsrc2);

    QOpenGLShader *fshader2 = new QOpenGLShader(QOpenGLShader::Fragment, &program2);
    const char *fsrc2 =
        "varying highp vec2 textureXYout;                       \n"
        "uniform sampler2D texture;                             \n"
        "void main(void)                                        \n"
        "{                                                      \n"
        "   gl_FragColor = texture2D(texture, textureXYout);    \n"
        "}                                                      \n";

    fshader2->compileSourceCode(fsrc2);

    program2.addShader(vshader2);
    program2.addShader(fshader2);
    program2.link();

    vertexAttr2 = program2.attributeLocation("position");
    textureInAttr2 = program2.attributeLocation("textureXYin");
    textureUniform2 = program2.uniformLocation("texture");

    textureVertices << QVector3D(-1.0, 1.0, 0.0) << QVector3D(-1.0, -1.0, 0.0)
                    << QVector3D(1.0, 1.0, 0.0) << QVector3D(1.0, -1.0, 0.0);

    UIView* view = m_data->view;

    width = nextHighestPowerOf2((quint32)view.bounds.size.width);
    height = nextHighestPowerOf2((quint32)view.bounds.size.height);
    double pctWidth = (double)(view.bounds.size.width) / (double)width;
    double pctHeight = (double)(view.bounds.size.height) / (double)height;

    qDebug() << "pctWidth:" << pctWidth << width;
    qDebug() << "pctHeight:" << pctHeight << height;
    textureCoords << QVector2D(0.0, 1 - pctHeight)
                  << QVector2D(0.0, 1)
                  << QVector2D(pctWidth, 1 - pctHeight)
                  << QVector2D(pctWidth, 1);

    // make space for an RGBA image of the view
    pixelBuffer = (GLubyte*) calloc(4 * width * height, sizeof(GLubyte));

    // create a suitable CoreGraphics context
    m_renderObjects->colorSpace = CGColorSpaceCreateDeviceRGB();
    m_renderObjects->context = CGBitmapContextCreate(pixelBuffer,
                                    width, height,
                                    8, 4 * width,
                                    m_renderObjects->colorSpace,
                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
}

void SpritzRenderer::render()
{
    [[m_data->view.subviews objectAtIndex:0] setNeedsDisplay];

    glGenTextures(1, &textureId);
    grabSpritzViewPixels();

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    program2.bind();
    program2.enableAttributeArray(vertexAttr2);
    program2.enableAttributeArray(textureInAttr2);
    program2.setAttributeArray(vertexAttr2, textureVertices.constData());
    program2.setAttributeArray(textureInAttr2, textureCoords.constData());
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(textureUniform2, 0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, textureVertices.size());
    program2.disableAttributeArray(textureInAttr2);
    program2.disableAttributeArray(vertexAttr2);
    program2.release();

    glDisable(GL_BLEND);
    glDeleteTextures(1, &textureId);
}

void SpritzRenderer::grabSpritzViewPixels()
{
    // draw the view to the buffer
    CGContextClearRect(m_renderObjects->context, CGRectMake(0, 0, width, height));
    [m_data->view.layer renderInContext:m_renderObjects->context];

    glBindTexture(GL_TEXTURE_2D, textureId);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, pixelBuffer);

    glBindTexture(GL_TEXTURE_2D, 0);
}

quint32 SpritzRenderer::nextHighestPowerOf2(quint32 num)
{
    if ((num & (num - 1)) == 0) return num;

    quint32 shifted = num;
    shifted--;
    shifted |= shifted >> 1;
    shifted |= shifted >> 2;
    shifted |= shifted >> 4;
    shifted |= shifted >> 8;
    shifted |= shifted >> 16;
    shifted++;
    return shifted;
}
