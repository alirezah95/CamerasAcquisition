#ifndef WEBCAMIMAGEPROVIDER_HPP
#define WEBCAMIMAGEPROVIDER_HPP

#include <QQuickImageProvider>
#include <QQmlEngine>

#include <opencv2/videoio.hpp>

class WebcamImageProvider : public QQuickImageProvider
{
    Q_OBJECT
public:
    WebcamImageProvider();

    virtual QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    cv::VideoCapture m_capture;
};

#endif // WEBCAMIMAGEPROVIDER_HPP
