#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "config.h"

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        []() {
            QCoreApplication::exit(-1);
            return;
        },
        Qt::QueuedConnection);

    /* In debug mode 'ui' folder in source directory is added to import pathes
     * instead of folder in build directory. This is because changes in 'ui'
     * folder of build directory only updates after each build so QML Preview
     * can not detect changes is files in 'ui' folder of source directory until
     * it is build again. So 'ui' folder in source directory should be added to
     * import path list only in debug mode
     */
#ifdef QT_DEBUG
    engine.addImportPath(QML_UI_ROOT);
#else
    engine.addImportPath(QString(":/qt/qml/%1/ui").arg(MAIN_MODULE_NAME));
#endif

    engine.addImportPath("./external");

    engine.loadFromModule(MAIN_MODULE_NAME, "Main");

    return app.exec();
}
