% Örnek bir karmaşık CNN yapısı

% Giriş katmanı
giris_goruntu = randn(256, 256, 3); % Örnek bir renkli görüntü (RGB)

% Convolution katmanı 1
filtre1 = randn(5, 5, 3, 32); % 5x5 boyutunda, 3 kanallı, 32 adet filtre
conv1 = convn(giris_goruntu, filtre1, 'same');
conv1_relu = max(0, conv1);

% Max-pooling katmanı 1
pool1 = zeros(size(conv1_relu) / 2);
for i = 1:2:size(conv1_relu, 1)
    for j = 1:2:size(conv1_relu, 2)
        pool1((i+1)/2, (j+1)/2, :) = max(max(conv1_relu(i:i+1, j:j+1, :)));
    end
end

% Convolution katmanı 2
filtre2 = randn(3, 3, 32, 64); % 3x3 boyutunda, 32 kanallıdan 64 kanallıya
conv2 = convn(pool1, filtre2, 'same');
conv2_relu = max(0, conv2);

% Max-pooling katmanı 2
pool2 = zeros(size(conv2_relu) / 2);
for i = 1:2:size(conv2_relu, 1)
    for j = 1:2:size(conv2_relu, 2)
        pool2((i+1)/2, (j+1)/2, :) = max(max(conv2_relu(i:i+1, j:j+1, :)));
    end
end

% Tam bağlantılı katman
fc_weights = randn(512, numel(pool2)); % 512 nöronlu tam bağlantılı katman
fc_input = reshape(pool2, [], 1); % Vektörleştirme
fc_output = fc_weights * fc_input;
fc_output_relu = max(0, fc_output);

% Sınıflandırma (softmax aktivasyonu)
num_classes = 10; % Örnek olarak 10 sınıf
softmax_weights = randn(num_classes, 512);
softmax_scores = softmax_weights * fc_output_relu;
