%{
opencv_path = 'D:\programlar\OpenCV\build';
opencv_include_path = fullfile(opencv_path, 'include');
opencv_lib_path = fullfile(opencv_path, 'x64', 'vc14', 'lib');
opencv_libs = {'opencv_core420', 'opencv_imgcodecs420', 'opencv_highgui420'};

% MEX komutunu kullanarak OpenCV fonksiyonlarını derleme
mex(['-I' opencv_include_path], ...
    ['-L' opencv_lib_path], ...
    ['-l' opencv_libs{1}], ...
    ['-l' opencv_libs{2}], ...
    ['-l' opencv_libs{3}], ...
    'readImage.cpp');

% Görüntüyü okumak için MEX dosyasını çağırma
img = readImage('image.jpg');

% Görüntüyü gösterme
imshow(img);


%}

% OpenCV kurulum yolunu ve kütüphane adlarını ayarlayın
opencv_path = 'D:\programlar\OpenCV\build';
opencv_include_path = fullfile(opencv_path, 'include');
opencv_lib_path = fullfile(opencv_path, 'x64', 'vc16', 'lib');

% Kütüphane dosyalarının tam adlarını kontrol edin
opencv_libs = {'opencv_core441', 'opencv_imgcodecs441', 'opencv_highgui441'}; % OpenCV sürümünüze göre kütüphane adlarını güncelleyin

% MEX komutunu çalıştırın
mex(['-I' opencv_include_path], ...
    ['-L' opencv_lib_path], ...
    ['-l' opencv_libs{1}], ...
    ['-l' opencv_libs{2}], ...
    ['-l' opencv_libs{3}], ...
    'readImage.cpp');
