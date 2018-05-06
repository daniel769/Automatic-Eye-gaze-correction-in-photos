close all;
A = imread('C:\M.Sc\Color Vision\EyeLookingCorrection\New\images\frontal_view_model.jpg');
B = imread('C:\M.Sc\Color Vision\EyeLookingCorrection\New\images\angelina_jolie.jpg');

%A = imread('left_eye.jpg');
%B = imread('right_eye.jpg');
gsA = rgb2gray(A);
gsB = rgb2gray(B); 

rect = face_detect(A);
croped = A(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3));
[El, Er, Ml, Mr, boxes] = my_find_eye(A);
gsEl = rgb2gray(uint8(El));
L =im2bw(gsEl, graythresh(gsEl));
figure; imshow(L, []);
[ newim ] = GazeCorrect(uint8(El));