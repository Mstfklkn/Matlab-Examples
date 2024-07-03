% Simülasyon için örnek veriler oluşturma

% Zaman vektörü
time = 0:0.1:100;

% GPS verileri (örneğin pozisyon)
gps_position = [time' + randn(size(time'))*0.5, time' + randn(size(time'))*0.5];

% IMU verileri (örneğin hız)
imu_velocity = [ones(size(time')), ones(size(time'))] + randn(length(time), 2)*0.1;

% Lidar verileri (örneğin pozisyon)
lidar_position = [time' + randn(size(time'))*0.2, time' + randn(size(time'))*0.2];





% Durum vektörü: [x; y; vx; vy]
% x ve y pozisyon, vx ve vy hız bileşenleridir.

% Durum geçiş matrisi (F)
dt = 0.1; % Zaman adımı
F = [1 0 dt 0;
     0 1 0 dt;
     0 0 1 0;
     0 0 0 1];

% GPS ve Lidar ölçüm matrisi (sadece pozisyon ölçülüyor)
H_gps = [1 0 0 0;
         0 1 0 0];

H_lidar = [1 0 0 0;
           0 1 0 0];

% IMU ölçüm matrisi (sadece hız ölçülüyor)
H_imu = [0 0 1 0;
         0 0 0 1];




% Süreç gürültüsü kovaryans matrisi (Q)
Q = 0.01 * eye(4);

% GPS ölçüm gürültüsü kovaryans matrisi (R_gps)
R_gps = 0.1 * eye(2);

% Lidar ölçüm gürültüsü kovaryans matrisi (R_lidar)
R_lidar = 0.05 * eye(2);

% IMU ölçüm gürültüsü kovaryans matrisi (R_imu)
R_imu = 0.1 * eye(2);




% Başlangıç durumu ve kovaryans matrisi
initial_state = [0; 0; 0; 0];
initial_covariance = eye(4);



% Kalman filtresi başlangıç durumu
x = initial_state;
P = initial_covariance;

% Birleşik durumları depolamak için yer ayırma
estimated_positions = zeros(length(time), 2);

for k = 1:length(time)
    % Tahmin adımı
    x = F * x;
    P = F * P * F' + Q;
    
    % GPS ölçüm yenileme adımı
    z_gps = gps_position(k, :)'; % GPS pozisyon ölçümü
    y_gps = z_gps - H_gps * x; % Ölçüm yeniliği
    S_gps = H_gps * P * H_gps' + R_gps; % Yenilik kovaryansı
    K_gps = P * H_gps' / S_gps; % Kalman kazancı
    
    x = x + K_gps * y_gps; % Durum güncelleme
    P = (eye(4) - K_gps * H_gps) * P; % Kovaryans güncelleme
    
    % IMU ölçüm yenileme adımı
    z_imu = imu_velocity(k, :)'; % IMU hız ölçümü
    y_imu = z_imu - H_imu * x; % Ölçüm yeniliği
    S_imu = H_imu * P * H_imu' + R_imu; % Yenilik kovaryansı
    K_imu = P * H_imu' / S_imu; % Kalman kazancı
    
    x = x + K_imu * y_imu; % Durum güncelleme
    P = (eye(4) - K_imu * H_imu) * P; % Kovaryans güncelleme
    
    % Lidar ölçüm yenileme adımı
    z_lidar = lidar_position(k, :)'; % Lidar pozisyon ölçümü
    y_lidar = z_lidar - H_lidar * x; % Ölçüm yeniliği
    S_lidar = H_lidar * P * H_lidar' + R_lidar; % Yenilik kovaryansı
    K_lidar = P * H_lidar' / S_lidar; % Kalman kazancı
    
    x = x + K_lidar * y_lidar; % Durum güncelleme
    P = (eye(4) - K_lidar * H_lidar) * P; % Kovaryans güncelleme
    
    % Tahmin edilen pozisyonları kaydet
    estimated_positions(k, :) = x(1:2)';
end

% Sonuçları çizme
figure;
plot(time, gps_position(:, 1), 'r--', 'DisplayName', 'GPS X');
hold on;
plot(time, lidar_position(:, 1), 'g--', 'DisplayName', 'Lidar X');
plot(time, estimated_positions(:, 1), 'b-', 'DisplayName', 'Fused X');
xlabel('Time (s)');
ylabel('Position X (m)');
legend;
title('Sensor Fusion using Kalman Filter with GPS, IMU, and Lidar');
