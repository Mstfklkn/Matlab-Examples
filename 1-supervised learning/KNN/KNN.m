% 1. Veri setini yükleme ve hazırlama
load fisheriris;
X = meas; % Özellikler (4 özellik)
Y = species; % Sınıf etiketleri (setosa, versicolor, virginica)

% Veriyi eğitim ve test setlerine ayırma
cv = cvpartition(Y, 'HoldOut', 0.3);
idxTrain = training(cv);
idxTest = test(cv);
XTrain = X(idxTrain, :);
YTrain = Y(idxTrain);
XTest = X(idxTest, :);
YTest = Y(idxTest);

% 2. KNN modelini eğitme
k = 5; % Komşu sayısı
mdl = fitcknn(XTrain, YTrain, 'NumNeighbors', k);

% 3. Modeli test etme ve performansı değerlendirme
YPred = predict(mdl, XTest);

% Doğruluğu hesaplama (cell dizileri için strcmp kullanılmalıdır)
correct = 0;
for i = 1:numel(YTest)
    if strcmp(YTest{i}, YPred{i})
        correct = correct + 1;
    end
end
accuracy = correct / numel(YTest);
fprintf('KNN model doğruluğu: %.2f\n', accuracy);

% 4. Sonuçları görselleştirme
% İlk iki özelliği kullanarak sınıflandırma sonuçlarını görselleştirme
figure;
gscatter(XTest(:, 1), XTest(:, 2), YTest);
hold on;
gscatter(XTest(:, 1), XTest(:, 2), YPred, 'mc', '*', 10);
xlabel('Özellik 1');
ylabel('Özellik 2');
title(sprintf('KNN Sınıflandırma Sonuçları (k = %d)\nDoğruluk: %.2f', k, accuracy));
legend('Setosa (Gerçek)', 'Versicolor (Gerçek)', 'Virginica (Gerçek)', ...
       'Setosa (Tahmin)', 'Versicolor (Tahmin)', 'Virginica (Tahmin)', 'Location', 'Best');
grid on;
hold off;
