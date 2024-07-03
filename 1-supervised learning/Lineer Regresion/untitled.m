% 1. Rastgele bir veri seti oluştur
n = 100; % Veri noktası sayısı
x = linspace(0, 10, n);
y = 3 * x + 5 + randn(1, n); % Gerçek eğim 3, y-kesim noktası 5 ve rastgele gürültü

% 2. Doğrusal regresyon modelini hesapla
p = polyfit(x, y, 1);

% Elde edilen eğim (m) ve y-kesim noktası (b)
m = p(1);
b = p(2);

% 3. Modeli değerlendirmek için istatistiksel ölçütleri hesapla
y_fit = polyval(p, x);
residuals = y - y_fit;
SS_res = sum(residuals.^2);
SS_tot = sum((y - mean(y)).^2);
R2 = 1 - (SS_res / SS_tot);

% 4. Sonuçları görselleştir
figure;
scatter(x, y, 'o', 'MarkerSize', 5, 'DisplayName', 'Veriler');
hold on;
plot(x, y_fit, '-r', 'LineWidth', 2, 'DisplayName', 'Doğrusal Regresyon');
xlabel('x');
ylabel('y');
title(sprintf('Doğrusal Regresyon Örneği\nEğim: %.2f, Y-Kesim Noktası: %.2f, R^2: %.2f', m, b, R2));
legend('show');
grid on;
hold off;