#include "SpritzPlugin.h"
#include "SpritzView.h"
#include "QSpritzSDK.h"

#include <QtQml>

void SpritzPlugin::registerTypes(const char *uri)
{
    // @uri Qtino.Spritz
    qmlRegisterType<SpritzView>(uri, 1, 0, "SpritzView");
    qmlRegisterUncreatableType<QSpritzSDK>(uri, 1, 0, "SpritzSDK", "The SpritzSDK object can only be accessed as an attached property of a SpritzView");
}


