% Adaptör adı
kameraAygiti = 'winvideo';

% Kamera cihazını oluştur
kamera = videoinput(kameraAygiti, 0, 'RGB24');

% Ekran penceresi oluştur
figure;

% Görüntü alma döngüsü
while true
    % Anlık görüntü al
    img = getsnapshot(kamera);
    
    % Görüntüyü göster
    imshow(img);
    
    % Çıkış için 'q' tuşuna basın
    if strcmpi(get(gcf,'CurrentCharacter'),'q')
        break;
    end
    
    drawnow;
end

% Kamerayı kapat
delete(kamera);
