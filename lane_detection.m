%% ROAD LANE DETECTION USING IMAGE PROCESSING

clc;
clear;
close all;

%% 1. Read the Road Image
img = imread('Road.jpg.jpeg');

figure;
imshow(img);
title('Original Road Image');

%% 2. Convert RGB Image to Grayscale
gray = rgb2gray(img);

figure;
imshow(gray);
title('Grayscale Image');

%% 3. Gaussian Filtering
blur = imgaussfilt(gray, 2);

figure;
imshow(blur);
title('Noise Reduction using Gaussian Filter');

%% 4. Canny Edge Detection
edges = edge(blur, 'Canny');

figure;
imshow(edges);
title('Canny Edge Detection');

%% 5. Region of Interest (ROI)
[rows, cols] = size(edges);

x = [0.05*cols, 0.95*cols, 0.58*cols, 0.42*cols];
y = [rows, rows, 0.43*rows, 0.43*rows];

mask = poly2mask(x, y, rows, cols);
roi = edges & mask;

figure;
imshow(roi);
title('Region of Interest');

%% 6. Hough Transform
[H, theta, rho] = hough(roi);

peaks = houghpeaks(H, 10, ...
    'Threshold', ceil(0.25 * max(H(:))));

lines = houghlines(roi, theta, rho, peaks, ...
    'FillGap', 50, 'MinLength', 40);

%% 7. Display All Detected Lines
figure;
imshow(img);
hold on;
title('Detected Lane Lines');

for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1), xy(:,2), 'g', 'LineWidth', 3);
end

hold off;

%% 8. Separate Left and Right Lane Lines
left_lines = [];
right_lines = [];

center_x = cols / 2;
y_top = 0.55 * rows;
y_bottom = rows;

for k = 1:length(lines)

    p1 = lines(k).point1;
    p2 = lines(k).point2;

    dx = p2(1) - p1(1);
    dy = p2(2) - p1(2);

    if abs(dy) < 1
        continue;
    end

    % Estimate line position at bottom and upper ROI
    x_bottom = p1(1) + ...
        (y_bottom - p1(2)) * dx / dy;

    x_top = p1(1) + ...
        (y_top - p1(2)) * dx / dy;

    % Ignore lines outside the image
    if x_bottom < 0 || x_bottom > cols || ...
       x_top < 0 || x_top > cols
        continue;
    end

    % Left lane: line moves toward image center at the top
    if x_bottom < center_x && x_top > x_bottom
        left_lines = [left_lines; ...
            x_bottom, x_top];

    % Right lane: line moves toward image center at the top
    elseif x_bottom > center_x && x_top < x_bottom
        right_lines = [right_lines; ...
            x_bottom, x_top];
    end
end

%% 9. Display Left Lane Only
figure;
imshow(img);
hold on;
title('Left Lane Detection');

for k = 1:size(left_lines,1)
    plot([left_lines(k,1), left_lines(k,2)], ...
         [y_bottom, y_top], 'r', 'LineWidth', 3);
end

hold off;

%% 10. Display Right Lane Only
figure;
imshow(img);
hold on;
title('Right Lane Detection');

for k = 1:size(right_lines,1)
    plot([right_lines(k,1), right_lines(k,2)], ...
         [y_bottom, y_top], 'b', 'LineWidth', 3);
end

hold off;

%% 11. Display Both Lanes
figure;
imshow(img);
hold on;
title('Final Road Lane Detection');

for k = 1:size(left_lines,1)
    plot([left_lines(k,1), left_lines(k,2)], ...
         [y_bottom, y_top], 'r', 'LineWidth', 3);
end

for k = 1:size(right_lines,1)
    plot([right_lines(k,1), right_lines(k,2)], ...
         [y_bottom, y_top], 'b', 'LineWidth', 3);
end

legend('Left Lane', 'Right Lane');
hold off;
