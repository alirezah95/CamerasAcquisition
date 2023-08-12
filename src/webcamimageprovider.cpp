#include "webcamimageprovider.hpp"

#include "opencv2/imgproc.hpp"

WebcamImageProvider::WebcamImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap WebcamImageProvider::requestPixmap(
    const QString& id, QSize* size, const QSize& requestedSize)
{
    if (id == "webcam") {
        if (!m_capture.isOpened()) {
            m_capture.open(0);
        }

        if (m_capture.isOpened()) {
            cv::Mat sourceImg;
            m_capture >> sourceImg;

            cv::Mat dest;
            cv::cvtColor(sourceImg, dest, cv::COLOR_BGR2RGB);

            QImage image = QImage((uchar*)dest.data, dest.cols, dest.rows,
                dest.step, QImage::Format_RGB888);

            return QPixmap::fromImage(image);
        }
    }

    return QPixmap();
}
