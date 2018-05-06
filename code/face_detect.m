function [rect] = face_detect( img )
%output: rect - [xmin, ymin, dx, dy]
% set mex file path for this platform ..
addpath(lower(computer));

% call without arguments to display help text ...
fprintf('\n--- fdlibmex help text ---\n');
fdlibmex;

% load an example image
%imgfilename = 'judybats.jpg';
%imgfilename = 'angelina_jolie.jpg';
if nargin < 1
imgfilename = 'frontal_view_model.jpg';
img = imread(imgfilename);
end
if size(img,3) == 3 %convert color to GS
    img = rgb2gray(img);
end

% run the detector
pos = fdlibmex(img);

% display the image
imagesc(img)
colormap gray
axis image
axis off

% draw red boxes around the detected faces
hold on
rect = [];
for i=1:size(pos,1)
    r = [pos(i,1)-pos(i,3)/2,pos(i,2)-pos(i,3)/2,pos(i,3),pos(i,3)];
    rect(i,:) = r;
    rectangle('Position', r, 'EdgeColor', [1,0,0], 'linewidth', 2);
end
hold off
[m, rectIdx] = max(pos(:,3));
rect = rect(rectIdx,:);
end
