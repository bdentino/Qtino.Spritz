#ifndef SPRITZSDK_H
#define SPRITZSDK_H

#include <QObject>
#include <QtQuick>
#include <QtQml>
#include "SpritzView.h"

class SpritzSDKAttachedType : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString clientId READ clientId WRITE setClientId NOTIFY credentialsChanged)
    Q_PROPERTY(QString clientSecret READ clientSecret WRITE setClientSecret NOTIFY credentialsChanged)

public:
    SpritzSDKAttachedType(QObject* parent = 0);

    const QString& clientId() const;
    const QString& clientSecret() const;

    void setClientId(const QString& clientId);
    void setClientSecret(const QString& clientSecret);

signals:
    void credentialsChanged();

private:
    void setupSDKCredentials();

    QString m_clientId;
    QString m_clientSecret;
};

class QSpritzSDK : public SpritzSDKAttachedType
{
    Q_OBJECT

public:
    static QSpritzSDK* qmlAttachedProperties(QObject* object);

protected:
    QSpritzSDK();

    static QSpritzSDK* s_SDKInstance;
};

QML_DECLARE_TYPEINFO(QSpritzSDK, QML_HAS_ATTACHED_PROPERTIES)

#endif // SPRITZSDK_H
