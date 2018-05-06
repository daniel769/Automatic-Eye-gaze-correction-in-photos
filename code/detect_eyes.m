function  [El, Er, Ml,Mr, boxes, skin_mask] = detect_eyes(im)

if nargin < 1
% imfilename = 'angelina_jolie.jpg';
% %imfilename = 'frontal_view_model.jpg';
% addpath(lower(computer));
% imfilename = 'clb1.jpg';   %good
% imfilename = '1.jpg';   %good
% imfilename = 'brigitte_bardot.jpg';   %good
% imfilename = 'antonio_banderas.jpg';  % good  -with Solidity limit 0.7 (was 0.8 before)
% imfilename = 'frontal_view_model.jpg'; %good
% imfilename = 'angelina_jolie.jpg';%good
% imfilename = 'brigitte_bardot.jpg';   %good
% imfilename = 'clb1.jpg';   %good
% imfilename = '1.jpg';   %good
% imfilename = 'brigitte-bardot-poster.jpg';   %good
% imfilename = 'Shimon_peres.jpg'
imfilename = 'frontal_view_model.jpg'; %good
im = imread(imfilename);
end
rect = face_detect(im);
if isempty(rect)
    exit('face was not detected');
end
im = imcrop(im,rect);
[im, skin_mask,I] = detect_skin(im);
[El, Er, Ml, Mr, boxes] = get_eyes_from_skin_mask(I, skin_mask); 
%real location of the box (not of the cropped!!)
boxes(:,1) = boxes(:,1)+rect(1);
boxes(:,2) = boxes(:,2)+rect(2);
El = uint8(El);
Er = uint8(Er);

