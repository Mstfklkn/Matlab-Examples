% 1. Veri setini yükleyin ve hazırlayın
load fisheriris;
X = meas; % Özellikler
Y = categorical(species); % Sınıf etiketlerini categorical türüne dönüştürün

% 2. Özellik mühendisliği yapın
% Özellikleri ölçeklendirin (z-score normalizasyonu)
X = zscore(X);

% Özellik seçimi (örneğin, ilk iki özelliği kullanın)
X = X(:, 1:2);

% Veriyi eğitim ve test setlerine bölün
cv = cvpartition(Y, 'HoldOut', 0.3); % Verinin %30'unu test seti olarak ayır
idx = cv.test;

% Eğitim ve test setlerini oluştur
XTrain = X(~idx, :);
YTrain = Y(~idx, :);
XTest = X(idx, :);
YTest = Y(idx, :);

% 3. Hiperparametre optimizasyonu ile Naive Bayes sınıflandırıcısını eğitin
% Hiperparametre optimizasyonu için ayarları belirleyin
opts = struct('Optimizer', 'bayesopt', 'ShowPlots', true, ...
    'CVPartition', cvpartition(YTrain, 'KFold', 5), ...
    'AcquisitionFunctionName', 'expected-improvement-plus');

% Hiperparametre aralığını belirleyin
paramGrid = hyperparameters('fitcnb', XTrain, YTrain);
paramGrid(1).Range = [0.1, 10]; % 'Width' hiperparametresi için aralık

% Modeli eğitin ve optimize edin
nbModel = fitcnb(XTrain, YTrain, 'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', opts);

% 4. Modeli çapraz doğrulama ile değerlendirin
CVModel = crossval(nbModel, 'KFold', 5);
accuracy = 1 - kfoldLoss(CVModel, 'LossFun', 'ClassifError');
fprintf('Çapraz doğrulama doğruluğu: %.2f\n', accuracy);

% 5. Sonuçları görselleştirin
YPred = predict(nbModel, XTest);

% Gerçek ve tahmin edilen sınıfları görselleştirin
figure;
gscatter(XTest(:,1), XTest(:,2), YTest);
hold on;
gscatter(XTest(:,1), XTest(:,2), YPred, 'rbg', 'xos');
legend('Setosa (Gerçek)', 'Versicolor (Gerçek)', 'Virginica (Gerçek)', ...
    'Setosa (Tahmin)', 'Versicolor (Tahmin)', 'Virginica (Tahmin)', 'Location', 'Best');
xlabel('Özellik 1 (Normalized)');
ylabel('Özellik 2 (Normalized)');
title('Naive Bayes Sınıflandırma Sonuçları');
grid on;
hold off;
