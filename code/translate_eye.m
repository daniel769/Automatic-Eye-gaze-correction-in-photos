function new_eye = translate_eye(eye_image)

%translation code
[r,c,d] = size(eyeImage);
% iris radius is iris(3), eyeball radius is 2*iris(3)
% from trigonometry:
dx = round(2*2*iris(3)*atan(thetaXrad)); 
dy = round(2*2*iris(3)*atan(thetaYrad));

eye0 = eyeImage.*uint8(eye_mask_l);

%eye = translateEye...
[X,Y] = meshgrid(1:c,1:r);
Xt = max(1,min(X-dx,r));
Yt= max(1,min(Y-dy,c));
eyeT2 = reshape(eye0,[r*c, 3 ,1 ]);
eyeT2 = eyeT2((Xt-1).*r+Yt, :);
eye1 = reshape(eyeT2,[r c 3]);

eye1 =uint8( eye1).*uint8(eye_mask_l);
save completeHolesData;

