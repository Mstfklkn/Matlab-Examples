% Simülasyon için örnek veriler oluşturma

% Zaman vektörü
time = 0:0.1:10;

% Gerçek pozisyon (örneğin bir aracın hareketi)
true_position = [sin(time'); cos(time')];

% Lidar verileri (örneğin pozisyon)
lidar1_position = true_position + randn(size(true_position))*0.2;
lidar2_position = true_position + randn(size(true_position))*0.2;

% ZED kamera verileri (örneğin pozisyon)
zed_position = true_position + randn(size(true_position))*0.3;

% Mesafe sensörü verileri (örneğin pozisyon)
distance1 = sqrt(sum((true_position + randn(size(true_position))*0.1).^2, 2));
distance2 = sqrt(sum((true_position + randn(size(true_position))*0.1).^2, 2));

% GPS verileri (örneğin pozisyon)
gps1_position = true_position + randn(size(true_position))*0.5;
gps2_position = true_position + randn(size(true_position))*0.5;




% Durum vektörü: [x; y; vx; vy]
% x ve y pozisyon, vx ve vy hız bileşenleridir.

% Durum geçiş matrisi (F)
dt = 0.1; % Zaman adımı
F = [1 0 dt 0;
     0 1 0 dt;
     0 0 1 0;
     0 0 0 1];

% Ölçüm matrisleri (pozisyon ölçülüyor)
H_position = [1 0 0 0;
              0 1 0 0];

% Mesafe sensörü ölçüm matrisi
H_distance1 = @(x) [x(1) / sqrt(x(1)^2 + x(2)^2), x(2) / sqrt(x(1)^2 + x(2)^2), 0, 0];
H_distance2 = @(x) [x(1) / sqrt(x(1)^2 + x(2)^2), x(2) / sqrt(x(1)^2 + x(2)^2), 0, 0];



% Süreç gürültüsü kovaryans matrisi (Q)
Q = 0.01 * eye(4);

% GPS ölçüm gürültüsü kovaryans matrisi (R_gps)
R_gps = 0.1 * eye(2);

% Lidar ölçüm gürültüsü kovaryans matrisi (R_lidar)
R_lidar = 0.05 * eye(2);

% ZED kamera ölçüm gürültüsü kovaryans matrisi (R_zed)
R_zed = 0.1 * eye(2);

% Mesafe sensörü ölçüm gürültüsü kovaryans matrisi (R_distance)
R_distance = 0.1;



% Başlangıç durumu ve kovaryans matrisi
initial_state = [0; 0; 0; 0];
initial_covariance = eye(4);


% Kalman filtresi başlangıç durumu
x = initial_state;
P = initial_covariance;

% Birleşik durumları depolamak için yer ayırma
estimated_positions = zeros(length(time), 2);

% Video oluşturma
video = VideoWriter('sensor_fusion_complex_simulation.avi');
open(video);

% Grafik oluşturma
figure;
hold on;
h1 = plot(nan, nan, 'r--', 'DisplayName', 'GPS1');
h2 = plot(nan, nan, 'm--', 'DisplayName', 'GPS2');
h3 = plot(nan, nan, 'g--', 'DisplayName', 'Lidar1');
h4 = plot(nan, nan, 'y--', 'DisplayName', 'Lidar2');
h5 = plot(nan, nan, 'c--', 'DisplayName', 'ZED');
h6 = plot(nan, nan, 'b-', 'DisplayName', 'Fused');
h7 = plot(nan, nan, 'k-', 'DisplayName', 'True Position');
xlabel('X Position (m)');
ylabel('Y Position (m)');
legend;
title('Sensor Fusion Simulation with Multiple Sensors');

axis equal;

for k = 1:length(time)
    % Tahmin adımı
    x = F * x;
    P = F * P * F' + Q;
    
    % GPS1 ölçüm yenileme adımı
    z_gps1 = gps1_position(k, :)'; % GPS1 pozisyon ölçümü
    y_gps1 = z_gps1 - H_position * x; % Ölçüm yeniliği
    S_gps1 = H_position * P * H_position' + R_gps; % Yenilik kovaryansı
    K_gps1 = P * H_position' / S_gps1; % Kalman kazancı
    
    x = x + K_gps1 * y_gps1; % Durum güncelleme
    P = (eye(4) - K_gps1 * H_position) * P; % Kovaryans güncelleme
    
    % GPS2 ölçüm yenileme adımı
    z_gps2 = gps2_position(k, :)'; % GPS2 pozisyon ölçümü
    y_gps2 = z_gps2 - H_position * x; % Ölçüm yeniliği
    S_gps2 = H_position * P * H_position' + R_gps; % Yenilik kovaryansı
    K_gps2 = P * H_position' / S_gps2; % Kalman kazancı
    
    x = x + K_gps2 * y_gps2; % Durum güncelleme
    P = (eye(4) - K_gps2 * H_position) * P; % Kovaryans güncelleme
    
    % Lidar1 ölçüm yenileme adımı
    z_lidar1 = lidar1_position(k, :)'; % Lidar1 pozisyon ölçümü
    y_lidar1 = z_lidar1 - H_position * x; % Ölçüm yeniliği
    S_lidar1 = H_position * P * H_position' + R_lidar; % Yenilik kovaryansı
    K_lidar1 = P * H_position' / S_lidar1; % Kalman kazancı
    
    x = x + K_lidar1 * y_lidar1; % Durum güncelleme
    P = (eye(4) - K_lidar1 * H_position) * P; % Kovaryans güncelleme
    
    % Lidar2 ölçüm yenileme adımı
    z_lidar2 = lidar2_position(k, :)'; % Lidar2 pozisyon ölçümü
    y_lidar2 = z_lidar2 - H_position * x; % Ölçüm yeniliği
    S_lidar2 = H_position * P * H_position' + R_lidar; % Yenilik kovaryansı
    K_lidar2 = P * H_position' / S_lidar2; % Kalman kazancı
    
    x = x + K_lidar2 * y_lidar2; % Durum güncelleme
    P = (eye(4) - K_lidar2 * H_position) * P; % Kovaryans güncelleme
    
    % ZED kamera ölçüm yenileme adımı
    z_zed = zed_position(k, :)'; % ZED pozisyon ölçümü
    y_zed = z_zed - H_position * x; % Ölçüm yeniliği
    S_zed = H_position * P * H_position' + R_zed; % Yenilik kovaryansı
    K_zed = P * H_position' / S_zed; % Kalman kazancı
    
    x = x + K_zed * y_zed; % Durum güncelleme
    P = (eye(4) - K_zed * H_position) * P; % Kovaryans güncelleme
    
    % Mesafe sensörü 1 ölçüm yenileme adımı
    z_distance1 = distance1(k); % Mesafe sensörü 1 ölçümü
    H_d1 = H_distance1(x);
    y_distance1 = z_distance1 - H_d1 * x; % Ölçüm yeniliği
    S_distance1 = H_d1 * P * H_d1' + R_distance; % Yenilik kovaryansı
    K_distance1 = P * H_d1' / S_distance1; % Kalman kazancı
    
    x = x + K_distance1 * y_distance1; % Durum güncelleme
    P = (eye(4) - K_distance1 * H_d1) * P; % Kovaryans güncelleme
    
    % Mesafe sensörü 2 ölçüm yenileme adımı
    z_distance2 = distance2(k); % Mesafe sensörü 2 ölçümü
    H_d2 = H_distance2(x);
    y_distance2 = z_distance2 - H_d2 * x; % Ölçüm yeniliği
    S_distance2 = H_d2 * P * H_d2' + R_distance; % Yenilik kovaryansı
    K_distance2 = P * H_d2' / S_distance2; % Kalman kazancı
    
    x = x + K_distance2 * y_distance2; % Durum güncelleme
    P = (eye(4) - K_distance2 * H_d2) * P; % Kovaryans güncelleme
    
    % Tahmin edilen pozisyonları kaydet
    estimated_positions(k, :) = x(1:2)';
    
    % Grafiği güncelleme
    set(h1, 'XData', gps1_position(1:k, 1), 'YData', gps1_position(1:k, 2));
    set(h2, 'XData', gps2_position(1:k, 1), 'YData', gps2_position(1:k, 2));
    set(h3, 'XData', lidar1_position(1:k, 1), 'YData', lidar1_position(1:k, 2));
    set(h4, 'XData', lidar2_position(1:k, 1), 'YData', lidar2_position(1:k, 2));
    set(h5, 'XData', zed_position(1:k, 1), 'YData', zed_position(1:k, 2));
    set(h6, 'XData', estimated_positions(1:k, 1), 'YData', estimated_positions(1:k, 2));
    set(h7, 'XData', true_position(1:k, 1), 'YData', true_position(1:k, 2));
    
    % Çerçeveyi videoya ekleme
    frame = getframe(gcf);
    writeVideo(video, frame);
    
    pause(0.01); % Simülasyon hızını ayarlama
end

% Video kapatma
close(video);

