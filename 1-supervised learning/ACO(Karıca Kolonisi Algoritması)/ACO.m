% Şehirlerin koordinatları
cities = [0, 0; 1, 3; 4, 3; 6, 1; 3, 0; 2, 2; 5, 5; 7, 2; 6, 4; 4, 1];
numCities = size(cities, 1);

% ACO Parametreleri
numAnts = 30;         % Karınca sayısı
numIterations = 200; % İterasyon sayısı
alpha = 1;           % Feromonun etkisi
beta = 2;            % Mesafe bilgisinin etkisi
rho = 0.5;           % Feromon buharlaşma oranı
Q = 100;             % Feromon güncelleme katsayısı
localUpdate = 0.5;   % Yerel Feromon Güncelleme Katsayısı

% Feromon ve Mesafe Matrisleri
pheromone = ones(numCities, numCities);
distances = sqrt((cities(:,1) - cities(:,1)').^2 + (cities(:,2) - cities(:,2)').^2);
distances(distances == 0) = inf; % Kendisine dönüş mesafesi sonsuz

% ACO Algoritmasını Başlat
bestTour = [];
bestLength = inf;
allBestTours = zeros(numIterations, numCities+1); % Her iterasyonun en iyi turu
allBestLengths = zeros(numIterations, 1); % Her iterasyonun en iyi uzunluğu

% Görselleştirme
figure;
hold on;
plot(cities(:,1), cities(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
for i = 1:numCities
    text(cities(i,1), cities(i,2), sprintf('%d', i), 'FontSize', 12, 'FontWeight', 'bold');
end
title('Karınca Kolonisi Algoritması - TSP Çözümü');
xlabel('X Koordinatları');
ylabel('Y Koordinatları');

% Iterasyon Başına En İyi Turu ve Uzunluğu Görselleştirme
for iteration = 1:numIterations
    allTours = zeros(numAnts, numCities + 1);
    allLengths = zeros(numAnts, 1);
    
    for ant = 1:numAnts
        % Her karınca için rastgele başlangıç şehri
        currentCity = randi(numCities);
        tour = currentCity;
        visitedCities = zeros(1, numCities);
        visitedCities(currentCity) = 1;
        
        for step = 1:(numCities - 1)
            % Geçerli şehirden diğer şehirler arasında seçim yap
            probabilities = zeros(1, numCities);
            for nextCity = 1:numCities
                if ~visitedCities(nextCity)
                    probabilities(nextCity) = (pheromone(currentCity, nextCity)^alpha) * ((1 / distances(currentCity, nextCity))^beta);
                end
            end
            probabilities = probabilities / sum(probabilities);
            nextCity = find(rand <= cumsum(probabilities), 1);
            
            % Şehri tura ekle
            tour = [tour, nextCity];
            visitedCities(nextCity) = 1;
            currentCity = nextCity;
        end
        
        % Turu tamamla
        tour = [tour, tour(1)];
        allTours(ant, :) = tour;
        allLengths(ant) = sum(distances(sub2ind([numCities, numCities], tour(1:end-1), tour(2:end))));
        
        % En iyi çözümü güncelle
        if allLengths(ant) < bestLength
            bestLength = allLengths(ant);
            bestTour = tour;
        end
    end
    
    % Feromon Güncelleme
    % Küresel güncelleme - en iyi tur üzerinden
    pheromone = (1 - rho) * pheromone;
    for ant = 1:numAnts
        for i = 1:numCities
            pheromone(allTours(ant, i), allTours(ant, i+1)) = pheromone(allTours(ant, i), allTours(ant, i+1)) + Q / allLengths(ant);
        end
    end
    
    % Yerel Feromon Güncelleme
    for ant = 1:numAnts
        for i = 1:numCities
            pheromone(allTours(ant, i), allTours(ant, i+1)) = pheromone(allTours(ant, i), allTours(ant, i+1)) + localUpdate * Q / allLengths(ant);
        end
    end
    
    % En İyi Turu ve Uzunluğu Kaydet
    allBestTours(iteration, :) = bestTour;
    allBestLengths(iteration) = bestLength;
    
    % Sonuçları Göster ve Güncelle
    clf;
    hold on;
    plot(cities(:,1), cities(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    for i = 1:numCities
        text(cities(i,1), cities(i,2), sprintf('%d', i), 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    % En İyi Turu Çiz
    for i = 1:numCities
        plot([cities(bestTour(i),1), cities(bestTour(i+1),1)], [cities(bestTour(i),2), cities(bestTour(i+1),2)], 'b-', 'LineWidth', 2);
    end
    plot([cities(bestTour(end),1), cities(bestTour(1),1)], [cities(bestTour(end),2), cities(bestTour(1),2)], 'b-', 'LineWidth', 2);
    
    % Karıncaların yollarını Çiz
    for ant = 1:numAnts
        for i = 1:numCities
            plot([cities(allTours(ant, i),1), cities(allTours(ant, i+1),1)], [cities(allTours(ant, i),2), cities(allTours(ant, i+1),2)], 'k--', 'LineWidth', 0.5);
        end
    end
    
    % Başlık ve Eksen Bilgisi
    title(sprintf('Iterasyon %d: En İyi Uzunluk = %.2f', iteration, bestLength));
    xlabel('X Koordinatları');
    ylabel('Y Koordinatları');
    pause(0.1); % Görselleştirmeyi güncellemek için kısa bir gecikme
end

% Sonuçları Göster
disp('En iyi tur:');
disp(bestTour);
disp('En iyi uzunluk:');
disp(bestLength);

% Sonuçları Grafikle Göster
figure;
hold on;
plot(cities(:,1), cities(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
for i = 1:numCities
    text(cities(i,1), cities(i,2), sprintf('%d', i), 'FontSize', 12, 'FontWeight', 'bold');
end

% En İyi Turu Çiz
for i = 1:numCities
    plot([cities(bestTour(i),1), cities(bestTour(i+1),1)], [cities(bestTour(i),2), cities(bestTour(i+1),2)], 'b-', 'LineWidth', 2);
end
plot([cities(bestTour(end),1), cities(bestTour(1),1)], [cities(bestTour(end),2), cities(bestTour(1),2)], 'b-', 'LineWidth', 2);

title(sprintf('Son Çözüm: En İyi Uzunluk = %.2f', bestLength));
xlabel('X Koordinatları');
ylabel('Y Koordinatları');
legend('Şehirler', 'En İyi Yol');
grid on;
