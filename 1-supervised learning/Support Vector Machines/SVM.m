% 1. Veri setini yükleyin ve hazırlayın
load fisheriris;
X = meas; % Özellikler
Y = species; % Sınıf etiketleri

% Veriyi eğitim ve test setlerine bölün
cv = cvpartition(Y, 'HoldOut', 0.3); % Verinin %30'unu test seti olarak ayır
idx = cv.test;

% Eğitim ve test setlerini oluştur
XTrain = X(~idx, :);
YTrain = Y(~idx, :);
XTest = X(idx, :);
YTest = Y(idx, :);

% Özellikleri standartlaştırın (z-score normalizasyonu)
mu = mean(XTrain);
sigma = std(XTrain);
XTrain = (XTrain - mu) ./ sigma;
XTest = (XTest - mu) ./ sigma;

% 2. Destek Vektör Makinesi modelini eğitin
t = templateSVM('KernelFunction', 'linear');
SVMModel = fitcecoc(XTrain, YTrain, 'Learners', t, 'Coding', 'onevsall');

% 3. Modeli test edin ve performansını değerlendirin
YPred = predict(SVMModel, XTest);

% Doğruluk hesaplama
accuracy = sum(strcmp(YPred, YTest)) / length(YTest);
fprintf('Model doğruluğu: %.2f\n', accuracy);

% 4. Sonuçları görselleştirin
% Sadece ilk iki özellik ile sonuçları görselleştireceğiz (2D)
XTrain2D = XTrain(:, 1:2);
XTest2D = XTest(:, 1:2);
t2D = templateSVM('KernelFunction', 'linear');
SVMModel_2D = fitcecoc(XTrain2D, YTrain, 'Learners', t2D, 'Coding', 'onevsall');

% Gerçek sınıfları görselleştirin
figure;
gscatter(XTest2D(:,1), XTest2D(:,2), YTest, 'rgb', 'osd');
hold on;

% Tahmin edilen sınıfları görselleştirin
YPred2D = predict(SVMModel_2D, XTest2D);
gscatter(XTest2D(:,1), XTest2D(:,2), YPred2D, 'rgb', 'x*');
xlabel('Özellik 1 (Standardized)');
ylabel('Özellik 2 (Standardized)');
title(sprintf('SVM Sınıflandırma Sonuçları\nDoğruluk: %.2f', accuracy));
legend('Setosa (Gerçek)', 'Versicolor (Gerçek)', 'Virginica (Gerçek)', ...
       'Setosa (Tahmin)', 'Versicolor (Tahmin)', 'Virginica (Tahmin)', 'Location', 'Best');
grid on;
hold off;
