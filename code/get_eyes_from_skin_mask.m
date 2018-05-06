
function [El, Er, Ml, Mr, boxes, I1] = get_eyes_from_skin_mask(I, skin_mask)
%[hue,sat,val] = rgb2hsv(I);
[H, W] = size(skin_mask);
im1 = ~imclose(~skin_mask,strel('disk',5));
imshow(im1)
im2 = ~imopen(~im1,strel('disk',4));
imshow(im2)
im3 = ~imclose(~im2,strel('disk',5));
imshow(im3)

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
   if  any(s(i).PixelList(:,2) > uint8(H/2)) ||...     %
       s(i).Solidity < .7 || ...
      (s(i).Area / imgArea)  < 0.01 % ||...               %was 0.01 
      %any(s(i).PixelList(:,2)==H) % || ...
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
if s(1).Centroid(1) > s(2).Centroid(1)
    ss = s(1);
    s(1) = s(2);
    s(2) = ss;
end
centroids = cat(1, s.Centroid);
boxes = cat(1, s.BoundingBox);



%exapnding the bounding box, left for the right eye, and right for the left
%eye
boxes(:,3) = round(boxes(:, 3).*1.4);
boxes(:,4) = round(boxes(:, 4).*1.6);
boxes(:,1) = max (1, round(boxes(:, 1) - boxes(:, 3).*0.2));
boxes(:,2) = max (1, round(boxes(:, 2) - boxes(:, 4).*0.3));
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

range_l.x = max(1,boxes(1,1)):min(boxes(1,1)+boxes(1,3), size(I,2));
range_r.x = max(1,boxes(2,1)):min(boxes(2,1)+boxes(2,3), size(I,2));

range_l.y = max(1,boxes(1,2)):min(boxes(1,2)+boxes(1,4), size(I,1));
range_r.y = max(1,boxes(2,2)):min(boxes(2,2)+boxes(2,4), size(I,1));

El = I(range_l.y, range_l.x,:);
Er = I(range_r.y, range_r.x,:);

Ml = im5(range_l.y, range_l.x,:);
Mr = im5(range_r.y, range_r.x,:);


