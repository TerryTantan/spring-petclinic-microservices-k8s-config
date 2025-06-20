# Đồ án 3: Triển khai Observability cho petclinic
 
## I. Mô tả:
Trong môn học này các bạn được yêu cầu xây dựng một quy trình, hệ thống ci/cd và monitor để có thể deploy, vận hành và giám sát được hệ thống petclinic từ link sau: https://github.com/spring-petclinic/spring-petclinic-microservices
Petclinic là hệ thống dùng để quản lý việc khám và trị bệnh của thú cưng được xây dựng dựa trên kiến trúc microservices như sau:
![Alt text](image-doan3.png)
Eureka-Service(Discovery-server): đây là dịch vụ cho phép đăng ký và tìm kiếm các service trong hệ thống
Admin-server: dùng để quản lý và monitor các service bên trong hệ thống petclinic
Zipkin: sử dụng cho tracing là distributed logging.
API-Gateway: cung cấp UI và gateway cho các internal service
Customers-service: đây là dịch vụ quản lý khách hàng
Genai-service: cung cấp hệ thống chatbot
Vets-service:  Quản lý thông tin về bác sĩ thú y
Visit-service(Pets): Quản lý thông tin về lần khám chữa bệnh cho pet của khách hàng.
## II. Yêu cầu
Đây là đồ án thứ 3 trong chuỗi đồ án môn học DevOps, Ở đồ án 2 các bạn dã triển khai hệ thống petclinic trên k8s. Trong đồ án này các bạn cần phải sử dụng Zipkins, Prometheus và Grafana Loki và Grafana để cung cấp khả năng Observability cho petclinic
1.	Cài đặt Prometheus, Grafana Loki, Grafana và Zipkins
2.	Cấu hình để hệ thông gửi trace lên Zipkins
3.	Cấu hình để hệ thống gửi metrics lên Prometheus. Trong yêu cầu này các bạn cần coi các service đã sài acuator chưa, nếu chưa thì các bạn tự thêm vào
4.	Cấu hình để hệ thống gửi logs lên Grafana Loki
5.	Cấu hình Grafana để thể hiện biểu đồ về số lượng request đến, số lượng request xử lý thành công (mã 2xx), số lượng request xử lý lỗi (mã 5xx)
6.	Cấu hình Grafana để lấy log và hiện thị từ Grafana Loki
7.	Cấu hình Proemetheus để tạo alert khi số lượng request xử lý lỗi > 10 trong 30 giây
8.	Yêu cầu nâng cao: Cấu hình để có thể cung cáp mỗi liên hệ giữa metrics và logs của một request cụ thể.
## III. Qui định
1.      Đồ án làm nhóm 4 sinh viên
2.      Thời gian làm bài 2 tuần (26/05/2025)
3.      Nộp bài: Các bạn tạo file báo cáo gồm các thông tin sau
b.      Chụp hình các bước các bạn cấu hình
c.      Đặt tên file theo format <MSSV1>_<MSSV2>_<MSSV3>.docx. Thứ tự MSSV cần được sắp xếp tăng dần. Ví dụ nhóm có 3 SV là 23120000, 23120001, 23120002 thì đặt tên file là 23120000_23120001_23120002.docx, nếu có 2 sinh viên thì đặt tên 23120000_23120001.docx, nếu chỉ có 1 sinh viên thì đặt tên 23120000.docx
