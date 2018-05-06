function [im, skin_mask, I] = detect_skin(I)
if nargin < 1
  I = imread('img.jpg');
  [im, skin_mask] = detect_skin(I);
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
