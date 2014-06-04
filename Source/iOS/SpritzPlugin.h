#ifndef SPRITZPLUGIN_PLUGIN_H
#define SPRITZPLUGIN_PLUGIN_H

#include <QQmlExtensionPlugin>

class SpritzPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif // SPRITZPLUGIN_PLUGIN_H

