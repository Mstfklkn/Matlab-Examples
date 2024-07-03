% Örnek bir giriş görüntüsü (renkli, 256x256x3)
giris_goruntu = randn(256, 256, 3);


% Convolution katmanı 1
filtre1 = randn(5, 5, 3, 32); % 5x5 boyutunda, 3 kanallı, 32 adet filtre
conv1 = convn(giris_goruntu, filtre1, 'same');
conv1_relu = max(0, conv1);


% Max-pooling katmanı 1
pool1 = maxpool(conv1_relu, [2 2]);

% Normalizasyon (örnek olarak batch normalization)
% Normalizasyon işlemi burada örnek amaçlı gösterilmiştir
pool1_normalized = batchnorm(pool1);


% Convolution ve Pooling katmanları
num_layers = 8;
num_filters = [32, 64, 128, 128, 256, 256, 512, 512]; % Her katman için filtre sayısı
filter_size = [5, 5, 3, 3, 3, 3, 3, 3]; % Her katman için filtre boyutu

% İlk convolution katmanı
filtre = randn(filter_size(1), filter_size(1), 3, num_filters(1));
conv_layers{1} = convn(giris_goruntu, filtre, 'same');
relu_layers{1} = max(0, conv_layers{1});

% Sonraki convolution ve pooling katmanları
for layer = 2:num_layers
    filtre = randn(filter_size(layer), filter_size(layer), num_filters(layer-1), num_filters(layer));
    conv_layers{layer} = convn(relu_layers{layer-1}, filtre, 'same');
    relu_layers{layer} = max(0, conv_layers{layer});
    pooling_layers{layer} = maxpool(relu_layers{layer}, [2 2]);
end

% Son pooling katmanı
son_katman = pooling_layers{num_layers};

% Tam bağlantılı katman
fc_weights = randn(1024, numel(son_katman)); % 1024 nöronlu tam bağlantılı katman
fc_input = reshape(son_katman, [], 1); % Vektörleştirme
fc_output = fc_weights * fc_input;
fc_output_relu = max(0, fc_output);

% Sınıflandırma (softmax aktivasyonu)
num_classes = 10; % Örnek olarak 10 sınıf
softmax_weights = randn(num_classes, 1024);
softmax_scores = softmax_weights * fc_output_relu;
