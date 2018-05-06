function [new_eye , new_mask, iris_trans] = translate_iris(eyeImage, eye_mask, iris, correction_angle)
% eyeImage : cropped image of eye
%  correctionAngle = [thetaX,thetaY] : correction angles for x and y
thetaX = correction_angle(1);
thetaY = correction_angle(2);

thetaXrad = thetaX*pi/360;
thetaYrad = thetaY*pi/360;

%translation code
[r,c,d] = size(eyeImage);
% iris radius is iris.r, eyeball radius is 2*iris.r
% from trigonometry:
dx = round(2*2*iris.r*atan(thetaXrad)); 
dy = round(2*2*iris.r*atan(thetaYrad));

eye_only = eyeImage.*uint8(eye_mask);

iris_trans.x0 = iris.x0 + dx;
iris_trans.y0 = iris.y0 + dy;
iris_trans.r = iris.r;

[X,Y] = meshgrid(1:c,1:r);
Xt = max(1,min(X-dx,c));
Yt= max(1,min(Y-dy,r));

eye_translated = reshape(eye_only,[r*c, 3 ,1 ]);
eye_translated = eye_translated((Xt-1).*r+Yt, :);
eye_translated = reshape(eye_translated,[r c 3]);

mask_translated = reshape(eye_mask,[r*c, 3 ,1 ]);
mask_translated = mask_translated((Xt-1).*r+Yt, :);
mask_translated = reshape(mask_translated,[r c 3]);

eye_translated =uint8( eye_translated).*uint8(eye_mask);
new_eye  = eye_translated;
new_mask = mask_translated;

