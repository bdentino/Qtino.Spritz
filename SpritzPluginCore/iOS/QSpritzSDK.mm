#import <UIKit/UIKit.h>
#import <SpritzSDK.h>

#include "QSpritzSDK.h"

SpritzSDKAttachedType::SpritzSDKAttachedType(QObject* parent)
    : QObject(parent),
      m_clientId(""),
      m_clientSecret("")
{

}

const QString& SpritzSDKAttachedType::clientId() const
{
    return m_clientId;
}

const QString& SpritzSDKAttachedType::clientSecret() const
{
    return m_clientSecret;
}

void SpritzSDKAttachedType::setClientId(const QString& clientId)
{
    m_clientId = clientId;
    if (m_clientSecret == "") return;
    setupSDKCredentials();
}
void SpritzSDKAttachedType::setClientSecret(const QString& clientSecret)
{
    m_clientSecret = clientSecret;
    if (m_clientId == "") return;
    setupSDKCredentials();
}

void SpritzSDKAttachedType::setupSDKCredentials()
{
    qDebug() << "Setting up SDK credentials";
    NSString* id = m_clientId.toNSString();
    NSString* secret = m_clientSecret.toNSString();
    [SpritzSDK setClientID:id clientSecret:secret];
    emit credentialsChanged();
}

QSpritzSDK* QSpritzSDK::s_SDKInstance = 0;

QSpritzSDK::QSpritzSDK() : SpritzSDKAttachedType()
{

}

QSpritzSDK* QSpritzSDK::qmlAttachedProperties(QObject* object)
{
    if (!(qobject_cast<SpritzView*>(object)))
        return 0;
    if (!s_SDKInstance)
        s_SDKInstance = new QSpritzSDK();
    return s_SDKInstance;
}
