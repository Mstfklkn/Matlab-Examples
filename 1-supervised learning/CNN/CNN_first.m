% MNIST veri setini yükle
[XTrain, YTrain] = digitTrain4DArrayData;
[XTest, YTest] = digitTest4DArrayData;

% CNN mimarisini tanımla
layers = [
    imageInputLayer([28 28 1])
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer];

% Eğitim seçeneklerini tanımla
options = trainingOptions('adam', ...
    'MaxEpochs',10, ...
    'ValidationData',{XTest,YTest}, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

% Modeli eğit
net = trainNetwork(XTrain,YTrain,layers,options);

% Modeli test et ve doğruluğu değerlendir
YPred = classify(net,XTest);
accuracy = sum(YPred == YTest)/numel(YTest);

% Doğruluğu göster
disp("Test veri seti üzerindeki doğruluk: " + accuracy*100 + "%")
