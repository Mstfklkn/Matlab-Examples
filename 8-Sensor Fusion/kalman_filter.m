% Simülasyon için örnek veriler oluşturma

% Zaman vektörü
time = 0:0.1:100;

% GPS verileri (örneğin pozisyon)
gps_position = [time' + randn(size(time'))*0.5, time' + randn(size(time'))*0.5];

% IMU verileri (örneğin hız)
imu_velocity = [ones(size(time')), ones(size(time'))] + randn(length(time), 2)*0.1;



% Durum vektörü: [x; y; vx; vy]
% x ve y pozisyon, vx ve vy hız bileşenleridir.

% Durum geçiş matrisi (F)
dt = 0.1; % Zaman adımı
F = [1 0 dt 0;
     0 1 0 dt;
     0 0 1 0;
     0 0 0 1];

% Ölçüm matrisi (H) (sadece pozisyon ölçülüyor)
H = [1 0 0 0;
     0 1 0 0];



% Süreç gürültüsü kovaryans matrisi (Q)
Q = 0.01 * eye(4);

% Ölçüm gürültüsü kovaryans matrisi (R)
R = 0.1 * eye(2);




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
    
    % Ölçüm yenileme adımı
    z = gps_position(k, :)'; % GPS pozisyon ölçümü
    y = z - H * x; % Ölçüm yeniliği
    S = H * P * H' + R; % Yenilik kovaryansı
    K = P * H' / S; % Kalman kazancı
    
    x = x + K * y; % Durum güncelleme
    P = (eye(4) - K * H) * P; % Kovaryans güncelleme
    
    % Tahmin edilen pozisyonları kaydet
    estimated_positions(k, :) = x(1:2)';
end

% Sonuçları çizme
figure;
plot(time, gps_position(:, 1), 'r--', 'DisplayName', 'GPS X');
hold on;
plot(time, estimated_positions(:, 1), 'b-', 'DisplayName', 'Fused X');
xlabel('Time (s)');
ylabel('Position X (m)');
legend;
title('Sensor Fusion using Kalman Filter');
