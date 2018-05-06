function [ newim ] = GazeCorrect(Im )
%GAZECORRECT Summary of this function goes here
%   
% INPUTS:
%   correctionAngle = [thetaX,thetaY] : correction angles for x and y
%   direction
% OUTPUT:
%   newim : image of the rotated eye
close all;
if nargin < 1
    ImFileName = 'frontal_view_model.jpg';
    Im = imread(ImFileName);
end
   
[El, Er, Ml, Mr, boxes] = detect_eyes(Im);

new_eye_l = correct_eye(El,[10,5]);
new_eye_r = correct_eye(Er,[10,5]);

newim = Im;
%replacing into the whole image
newim(boxes(1,2):boxes(1,2)+boxes(1,4),boxes(1,1):boxes(1,1)+boxes(1,3),:) = new_eye_l;
newim(boxes(2,2):boxes(2,2)+boxes(2,4),boxes(2,1):boxes(2,1)+boxes(2,3),:) = new_eye_r;
figure;
subplot(1,2,1);imshow(Im);title('original');
subplot(1,2,2);imshow(newim);title('transformed');
%Here should the program end



