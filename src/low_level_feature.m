% author_name = Nicolas Drizard
% Low level features

% Loading images
%Ia=single(rgb2gray(imread('heads/whale_08017/w_1106.jpg')));
Ia=rgb2gray(imread('heads/whale_08017/w_6177.jpg'));

% Hog Features
[featureVector, hogVisualization] = extractHOGFeatures(Ia);

% Display them
figure;
imshow(Ia); hold on;
plot(hogVisualization);