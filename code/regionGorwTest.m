close all;
A = imread('C:\M.Sc\Color Vision\EyeLookingCorrection\New\images\frontal_view_model.jpg');
B = imread('C:\M.Sc\Color Vision\EyeLookingCorrection\New\images\angelina_jolie.jpg');

rectA = face_detect(A);
rectB = face_detect(B);
rect = rectA;
A = A(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:);
rect = rectB;
B = B(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:);

hsvA = rgb2hsv(A);
hsvB = rgb2hsv(B); 

valA = hsvA(:,:,3) ;
valB = hsvB(:,:,3) ;
figure; imshow(valA, []); impixelinfo;
figure; imshow(valB, []); impixelinfo;

% [x,y]

scleraA = [84,111];
scleraA = [scleraA valA(scleraA(1),scleraA(2))];
%scleraB = 
% 
irisA = [100,105];
irisA = [irisA valA(irisA(1),irisA(2))];
%irisB = 
mask_sc_A = regiongrowing(valA, scleraA(1), scleraA(2), scleraA(3)*0.1);
mask_ir_A = regiongrowing(valA, irisA(1), irisA(2), irisA(3)*0.1);
%mask_sc_B = regiongrowing(img, scleraB(1), scleraB(2), scleraB(3)*0.1);
%mask_ir_B = regiongrowing(img, irisB(1), irisB(2), irisB(3));