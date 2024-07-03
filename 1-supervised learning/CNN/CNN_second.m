% MNIST veri setini yükle
[XTrain, YTrain] = digitTrain4DArrayData;
[XTest, YTest] = digitTest4DArrayData;

% CNN mimarisini tanımla
layers = [
    imageInputLayer([28 28 1], 'Name', 'input')
    
    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv_1')
    batchNormalizationLayer('Name', 'batch_norm_1')
    reluLayer('Name', 'relu_1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'max_pool_1')
    
    convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv_2')
    batchNormalizationLayer('Name', 'batch_norm_2')
    reluLayer('Name', 'relu_2')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'max_pool_2')
    
    convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv_3')
    batchNormalizationLayer('Name', 'batch_norm_3')
    reluLayer('Name', 'relu_3')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'max_pool_3')
    
    dropoutLayer(0.5, 'Name', 'dropout')
    
    fullyConnectedLayer(512, 'Name', 'fc_1')
    reluLayer('Name', 'relu_fc_1')
    fullyConnectedLayer(10, 'Name', 'fc_2')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'output')];

% Ağın mimarisini görselleştir
analyzeNetwork(layers);
analyzeNetworkForCodegen(layers)

% Eğitim seçeneklerini tanımla
options = trainingOptions('adam', ...
    'MaxEpochs',20, ...
    'MiniBatchSize', 128, ...
    'ValidationData',{XTest,YTest}, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

% Modeli eğit
% net = trainNetwork(XTrain,YTrain,layers,options);

% Modeli test et ve doğruluğu değerlendir
% YPred = classify(net,XTest);
% accuracy = sum(YPred == YTest)/numel(YTest);

% Doğruluğu göster
% disp("Test veri seti üzerindeki doğruluk: " + accuracy*100 + "%")
