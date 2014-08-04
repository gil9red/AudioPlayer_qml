#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QWindow>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("AudioPlayer");
    app.setOrganizationName("IPetrash");
    app.setOrganizationDomain("ipetrash.org");
    app.setApplicationVersion("0.0.1");
    app.setApplicationDisplayName(QObject::trUtf8("QML example AudioPlayer v%1. Author Ilya Petrash").arg(app.applicationVersion()));

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("applicationTitle"), app.applicationDisplayName());

    QQmlContext * rootContext = engine.rootContext();
    const QStringList & musicPaths = QStandardPaths::standardLocations(QStandardPaths::MusicLocation);
    const QUrl musicUrl = QUrl::fromLocalFile(musicPaths.isEmpty() ? QDir::homePath() : musicPaths.first());
    rootContext->setContextProperty(QStringLiteral("musicUrl"), musicUrl);

    const QStringList arguments = QCoreApplication::arguments();
    const QUrl commandLineUrl = arguments.size() > 1 ? QUrl::fromLocalFile(arguments.at(1)) : QUrl();
    rootContext->setContextProperty(QStringLiteral("url"), commandLineUrl);

    engine.load(QUrl("qrc:/main.qml"));
    QObject * root = engine.rootObjects().first();
    QWindow * window = qobject_cast<QWindow *>(root);
    if (window)
        window->show();

    return app.exec();
}
