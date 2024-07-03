% Zaman serisi verisini oluştur
t = (0:0.01:10)'; % Zaman vektörü
X = sin(2*pi*0.1*t); % Sinüs dalgası verisi

% Giriş ve hedef verilerini oluştur
numTimeSteps = numel(X);
inputSeries = X(1:end-1);
targetSeries = X(2:end);

% Giriş ve hedef verilerini hücre dizilerine dönüştür
inputSeries = num2cell(inputSeries');
targetSeries = num2cell(targetSeries');

% RNN mimarisini tanımla
layers = [
    sequenceInputLayer(1, 'Name', 'input')
    lstmLayer(50, 'OutputMode', 'sequence', 'Name', 'lstm')
    fullyConnectedLayer(1, 'Name', 'fc')
    regressionLayer('Name', 'output')];

analyzeNetwork(layers)

% Eğitim seçeneklerini tanımla
options = trainingOptions('adam', ...
    'MaxEpochs',100, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.2, ...
    'LearnRateDropPeriod',50, ...
    'Verbose',0, ...
    'Plots','training-progress');

% Modeli eğit
net = trainNetwork(inputSeries, targetSeries, layers, options);

% Tahmin yap
YPred = predict(net, inputSeries);

% Tahmin sonuçlarını tekrar matrise dönüştür
YPred = cell2mat(YPred);

% Sonuçları görselleştir
figure
plot(t(1:end-1), cell2mat(inputSeries), 'b', 'DisplayName', 'Giriş')
hold on
plot(t(2:end), cell2mat(targetSeries), 'r', 'DisplayName', 'Gerçek')
plot(t(2:end), YPred, 'g', 'DisplayName', 'Tahmin')
legend
title('RNN ile Zaman Serisi Tahmini')
hold off
