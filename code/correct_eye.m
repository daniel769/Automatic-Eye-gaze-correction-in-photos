function new_eye = correct_eye(eye_image,correction_angle)

% find Iris, Pupil,  radius
%For the thresh program we need to give a bigger eye subwindow(since it
%needs to have the whole iris possible diameter to fit in the window
rmin = round(size(eye_image,1)/3);
rmax = round(size(eye_image,1)/2);
[iris,pupil,out_im]=find_iris(eye_image,rmin,rmax);
% [x,y,e,bestR, iris_mask]= find_iris_ours(eye_image);
 %iris.x0 = x;
 %iris.y0 = y;
 %iris.r = bestR;
% draw_iris(eye_image,x,y,bestR)


[eye_mask, sclera_mask, eye_edge] = SegmentEye(eye_image,iris);



%This is the iris translation part
[eye_trans , eye_mask_trans, iris_trans] = translate_iris(eye_image, eye_mask, iris, correction_angle);
%complete Holes
eye_filled = completeHoles(eye_image, eye_trans, eye_mask, eye_mask_trans, iris, iris_trans);

invMask = eye_mask-1;
invMask = invMask*(-1);
nonEyeRegion = uint8(eye_image).*uint8(invMask);
new_eye = eye_filled + nonEyeRegion;

function [dx,dy] = get_translation (eye_mask, iris)
STATS  = regionprops(eye_mask, 'centroid');
dx = STATS(1).Centroid(1)- iris.x0;
dy = STATS(1).Centroid(2) - iris.y0;

