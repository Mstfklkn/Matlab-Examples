% 1. Veri setini yükleme ve hazırlama
load fisheriris; % Iris veri setini yükle
X = meas; % Özellik matrisi
Y = species; % Sınıf etiketleri

% Veriyi eğitim ve test setlerine ayırma
cv = cvpartition(Y, 'HoldOut', 0.3);
idxTrain = training(cv);
idxTest = test(cv);
XTrain = X(idxTrain, :);
YTrain = Y(idxTrain);
XTest = X(idxTest, :);
YTest = Y(idxTest);

% 2. Karar ağacı modelini eğitme
treeModel = fitctree(XTrain, YTrain);

% 3. Modeli test etme ve performansı değerlendirme
YPred = predict(treeModel, XTest);

% Doğruluk hesaplama
correct = sum(strcmp(YTest, YPred));
accuracy = correct / numel(YTest);
fprintf('Karar ağacı model doğruluğu: %.2f\n', accuracy);

% 4. Sonuçları görselleştirme
view(treeModel, 'Mode', 'graph'); % Karar ağacının yapısını görselleştirme

% Özellikleri (meas) ve sınıfları (species) kullanarak sınıflandırma sonuçlarını görselleştirme
gscatter(XTest(:, 1), XTest(:, 2), YTest);
hold on;
gscatter(XTest(:, 1), XTest(:, 2), YPred, 'mc', '*', 10);
xlabel('Özellik 1');
ylabel('Özellik 2');
title(sprintf('Karar Ağacı Sınıflandırma Sonuçları\nDoğruluk: %.2f', accuracy));
legend('Setosa', 'Versicolor', 'Virginica', 'Tahmin Edilen Setosa', 'Tahmin Edilen Versicolor', 'Tahmin Edilen Virginica', 'Location', 'Best');
grid on;
hold off;
