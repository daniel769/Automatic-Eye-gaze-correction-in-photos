function  [El, Er, Ml,Mr, boxes, skin_mask] = detect_eyes(im)

if nargin < 1
imfilename = 'angelina_jolie.jpg';
%imfilename = 'frontal_view_model.jpg';
addpath(lower(computer));
imfilename = 'clb1.jpg';   %good
imfilename = '1.jpg';   %good
imfilename = 'brigitte_bardot.jpg';   %good
imfilename = 'antonio_banderas.jpg';  % good  -with Solidity limit 0.7 (was 0.8 before)
imfilename = 'frontal_view_model.jpg'; %good
imfilename = 'angelina_jolie.jpg';%good
imfilename = 'brigitte_bardot.jpg';   %good
imfilename = 'clb1.jpg';   %good
imfilename = '1.jpg';   %good
imfilename = 'brigitte-bardot-poster.jpg';   %good
imfilename = 'Shimon_peres.jpg'
imfilename = 'frontal_view_model.jpg'; %good
im = imread(imfilename);
end
rect = face_detect(im);
im = im(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:);
[im, skin_mask, I] = my_skin(im);
[El, Er, Ml, Mr, boxes, I1] = get_eyes(I, skin_mask); 
%real location of the box (not of the cropped!!)
boxes(:,1) = boxes(:,1)+rect(1);
boxes(:,2) = boxes(:,2)+rect(2);
El = uint8(El);
Er = uint8(Er);


function [im, skin_mask, I] = my_skin(I)
if nargin < 1
  % I = imread('frontal_view_model.jpg');
  I = imread('img.jpg');
  [im, skin_mask] = my_skin(I);
  imshow(im,[]);
  imshow(skin_mask,[])
  im = [];
  skin_mask = [];
  return
end


[hue, s, v]=rgb2hsv(I);

% YCbCr per ITU Rec. 601, the following equations, correct to three decimal places, can be used: 
% Y  =  0.257*R +0.504*G + 0.098*B + 16 
% Cb = -0.148*R -0.219*G + 0.439*B + 128 
% Cr =  0.439*R -0.386*G - 0.071*B + 128 

C = [ 0.148 -0.291  0.439 128;
      0.439 -0.368 -0.071 128] ;

I=double(I);   
cb =  C(1,1) * I(:,:,1) + C(1,2) * I(:,:,2) + C(1,3) * I(:,:,3) + C(1,4);
cr =  C(2,1) * I(:,:,1) + C(2,2) * I(:,:,2) + C(2,3) * I(:,:,3) + C(2,4);

skin_mask = 140 <= cb & cb <=195 & ...
            140 <= cr & cr <=165 &  ...
            0.01 <=hue  & hue <= 0.1;

im = zeros(size(I));
for i=1:3, im(:,:,i)=I(:,:,i).*skin_mask; end
im = uint8(im);

  





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


function [El, Er, Ml, Mr, boxes, I1] = get_eyes(I, skin_mask)
[hue,sat,val] = rgb2hsv(I);
[H, W] = size(skin_mask);
im1 = ~imclose(~skin_mask,strel('disk',5));
imshow(im1)
im2 = ~imopen(~im1,strel('disk',4));
im3 = ~imclose(~im2,strel('disk',5));

[L,n] = bwlabel(~im3);
s = regionprops(L, 'BoundingBox');
boxes=cat(1,s.BoundingBox);  %extract the boxes co-ordinates into a matrix
w = boxes(:,3); h = boxes(:,4);
im4 = ismember(L,find(h./w < 1));  % eye is wider 
[L,n] = bwlabel(im4);
s = regionprops(L, 'PixelList','Solidity', 'PixelIdxList', 'Area', 'ConvexArea' );
bad =zeros(n,1);
imgArea = size(L,1)*size(L,2);
for i=1:n
  imshow(L==i); hold on
  %if any(s(i).PixelList(:,1)==1) || any(s(i).PixelList(:,1)==W) || ...   %
  %contours     %BB
      %any(s(i).PixelList(:,2)==1) || ...
   if  any(s(i).PixelList(:,2) > uint8(H/3)) ||...     %
       s(i).Solidity < .7 || ...
      (s(i).Area / imgArea)  < 0.01                 %was 0.01 
      any(s(i).PixelList(:,2)==H) % || ...
      %var( hue(s(i).PixelIdxList)) < .001  || ...     %because of 1.jpg
      bad(i) = 1;
  end
end
%any(s(i).PixelList(:,2) > uint8(H/3)) ||...             %BB
      %any(s(i).PixelList(:,2)==H) || ...
      %(s(i).Area / imgArea) < 0.01 
      %(s(i).Area / imgArea) < 0.01 
im5 = ismember(L,find(~bad));

[L,n] = bwlabel(im5);
RGB = label2rgb(L);
imshow(RGB);
if n ~=2
  error('Did not find the eyes!');
end
s = regionprops(L, 'Centroid', 'BoundingBox');

%determine which blob is right and left eyes.
if s(1).Centroid(1) > s(2).Centroid(2)
    ss = s(1);
    s(1) = s(2);
    s(2) = ss;
end
centroids = cat(1, s.Centroid);
boxes = cat(1, s.BoundingBox);



%exapnding the bounding box, left for the right eye, and right for the left
%eye
boxes(:,3) = round(boxes(:, 3).*1.4);
boxes(:,1) = max (1, round(boxes(:, 1) - boxes(:, 3).*0.2));
%boxes(:,[3 4]) = boxes(:, [3 4]).*1.4;
%boxes(:,[1 2]) = (0.9)*boxes(:,[1 2]);
dy = abs(centroids(1,2)-centroids(2,2));
dh = min(boxes(1,4), boxes(2,4));
if dy > dh
  error('Pair not sufficiently aligned');
end

s = regionprops(L, 'all');

I1(:,:,1) = I(:,:,1).* im5;
I1(:,:,2) = I(:,:,2).* im5;
I1(:,:,3) = I(:,:,3).* im5;

range_l.x = boxes(1,1):min(boxes(1,1)+boxes(1,3), size(I,2));
range_r.x = boxes(2,1):min(boxes(2,1)+boxes(2,3), size(I,2));
El = I(boxes(1,2):boxes(1,2)+boxes(1,4), ...
        range_l.x,:);8
Er = I(boxes(2,2):boxes(2,2)+boxes(2,4), ...
        range_r.x,:);

Ml = im5(boxes(1,2):boxes(1,2)+boxes(1,4), ...
        range_l.x,:);
Mr = im5(boxes(2,2):boxes(2,2)+boxes(2,4), ...
        range_r.x,:);


