function mask = regiongrowing(img, x, y, reg_maxdist)
% This function performs "region growing" in an image from a specified
% seedpoint (x,y)
%
% mask = regiongrowing(I,x,y,t)
%
% I : input image
% mask : logical output image of region
% x,y : the position of the seedpoint (if not given uses function getpts)
% t : maximum intensity distance (defaults to 0.2)
%
% The region is iteratively grown by comparing all unallocated neighbouring pixels to the region.
% The difference between a pixel's intensity value and the region's mean,
% is used as a measure of similarity. The pixel with the smallest difference
% measured this way is allocated to the respective region.
% This process stops when the intensity difference between region mean and
% new pixel become larger than a certain treshold (t)
%
%
% Author: D. Kroon, University of Twente

if nargin == 0,
  img = im2double(imread('medtest.png'));
  y = 120; x = 120;
  x= 350; y=150;
  mask = regiongrowing(img,x,y,0.2);
  figure, imshow(img+mask); hold on
  plot(x,y,'r+');
  mask = [];
  return
end

if nargin < 4,
  reg_maxdist=0.2;
end

mask = zeros(size(img)); % Output
[H W]  = size(img); % Dimensions of input image

reg_mean = img(y,x); % The mean of the segmented region
reg_size = 1; % Number of pixels in region

% Free memory to store neighbours of the (segmented) region
allocation = 10000;
neigb_free = allocation; 
neigb_pos = 0;
neigb_list = zeros(neigb_free,3);

pixdist = 0; % Distance of the region newest pixel to the regio mean

% Neighbor locations (footprint)
neigb =[-1 0; 1 0; 0 -1;0 1];

% Start regiogrowing until distance between regio and posible 
% new pixels become higher than a certain treshold
while pixdist<reg_maxdist && reg_size<numel(img)

  % Add new neighbors pixels
  for j=1:4,
    % Calculate the neighbour coordinate
    xn = x + neigb(j,2);
    yn = y + neigb(j,1);
    % Check if neighbour is inside or outside the image
    inside = yn>=1 && xn>=1 && yn<=H && xn<=W;

    % Add neighbor if inside and not already part of 
    % the segmented area
    if inside && mask(yn,xn)==0
      neigb_pos = neigb_pos + 1;
      neigb_list(neigb_pos,:) = [yn xn img(yn,xn)]; 
      mask(yn,xn)=1;
    end
  end

  % Add a new block of free memory
  if neigb_pos > neigb_free - 10, 
    neigb_free=neigb_free+allocation; 
    neigb_list((neigb_pos+1):neigb_free,:)=0; 
  end

  % Add to the region the pixel with the intensity nearest to 
  % the mean of the region, 
  dist = abs(neigb_list(1:neigb_pos,3)-reg_mean);
  [pixdist, index] = min(dist);
  mask(y,x) = 2; 
  reg_size = reg_size+1;

  % Calculate the new mean of the region
  reg_mean= (reg_mean*reg_size + neigb_list(index,3))/(reg_size+1);

  % Save the x and y coordinates of the pixel (for the neighbour add
  % proccess)
  x = neigb_list(index,2);
  y = neigb_list(index,1);

  % Remove the pixel from the neighbour (check) list
  neigb_list(index,:) = neigb_list(neigb_pos,:); 
  neigb_pos = neigb_pos-1;
end

% Return the segmented area as logical matrix
mask = mask>1;