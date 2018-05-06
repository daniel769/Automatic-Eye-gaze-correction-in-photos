%% TAKE2

%eyeOnly = uint8(zeros(size(eyeImage)));
eyeOnly = eyeImage.*uint8(eyeMask);
% eyeOnly(:,:,1) = eyeImage(:,:,1).*uint8(eyeMask);
% eyeOnly(:,:,2) = eyeImage(:,:,2).*uint8(eyeMask);
% eyeOnly(:,:,3) = eyeImage(:,:,3).*uint8(eyeMask);
figure,imshow(eyeOnly);
% find Iris, Pupil,  radius
[iris,pupil,out_im]=thresh(eyeImage,20,30);

%define sphere
%sphere is all points (x,y,z)' where
% (x-rIrisL(1))^2 + (y-rIrisL(2))^2 + z^2 = rIrisL(3)
[srcX,srcY,srcZ] = im3scoords(eyeImage, iris);


%change origin of X and Y such that the eyeball center is the origin 0,0 (for
%rotating)

eyecenter = pupil(1:2); % TODO: can't assume pupil is the eye center! change to center of mass
srcX0 = srcX - eyecenter(1);
srcY0 = srcY - eyecenter(2);
srcZ0 = srcZ;

% calculate destination coordinates


XYZ = Ry([srcX0(:),srcY0(:),srcZ0(:)],thetaX, units);
XYZ = Rx(XYZ,thetaY, units);

tgtX0 = XYZ(:,1);
tgtY0 = XYZ(:,2);
tgtZ0 = XYZ(:,3);

% return origin to original coordinates
tgtX = tgtX0 + eyecenter(1);
tgtY = tgtY0 + eyecenter(2);
tgtZ = tgtZ0;

% srcX = Reshape(srcX,s(1),s(2));
% srcY = Reshape(srcY,s(1),s(2));
% srcZ = Reshape(srcZ,s(1),s(2));

tgtZ(tgtZ<0)=0;

% R = eyeImage(:,:,1);
% G = eyeImage(:,:,2);
% B = eyeImage(:,:,3);

TFORM = cp2tform([srcX(:),srcY(:)], [tgtX,tgtY], 'projective');
s = size(eyeImage);
movedEye = imtransform(eyeOnly,TFORM,'Size',s(1:2));

%movedEye=imresize(movedEye,s(1:2));
%figure,imshow(movedEye);

%newim = uint8(zeros(size(eyeImage)));
invMask = eyeMask-1;
invMask = invMask*(-1);
newim = eyeImage.*uint8(invMask);
%newim(:,:,2) = eyeImage(:,:,2).*(-1*(uint8(eyeMask)-1));
%newim(:,:,3) = eyeImage(:,:,3).*(-1*(uint8(eyeMask)-1));

newim = newim+movedEye;
figure;imshow(newim);


%% TAKE 1

% find Iris, Pupil,  radius
[iris,pupil,out_im]=thresh(eyeImage,20,30);

%define sphere
%sphere is all points (x,y,z)' where
% (x-rIrisL(1))^2 + (y-rIrisL(2))^2 + z^2 = rIrisL(3)
[X,Y,Z] = im3scoords(eyeImage, iris);

tgtX = X(:);
tgtY = Y(:);
tgtZ = Z(:);

% remove coordinates that are outside the eye segment
% tgtX = tgtX(eyeMask~=0);
% tgtY = tgtY(eyeMask~=0);
% tgtZ = tgtZ(eyeMask~=0);

%change origin of X and Y such that the eyeball center is the origin 0,0 (for
%rotating)

eyecenter = pupil(1:2); % TODO: can't assume pupil is the eye center! change to center of mass
tgtX0 = tgtX - eyecenter(1);
tgtY0 = tgtY - eyecenter(2);
tgtZ0 = tgtZ;

% calculate source coordinates
% the inverse mapping for rotating by angle 'theta' is equal to rotating by
% -'theta'

XYZ = Ry([tgtX0,tgtY0,tgtZ0],-thetaX, units);
XYZ = Rx(XYZ,-thetaY, units);
srcX0 = XYZ(:,1);
srcY0 = XYZ(:,2);
srcZ0 = XYZ(:,3);

% return origin to original coordinates
srcX = srcX0 + eyecenter(1);
srcY = srcY0 + eyecenter(2);
srcZ = srcZ0;

%  [row,col]=find(eyeMask~=0);
%  src = [srcX,srcY,srcZ];
%  [c,ia,ib] = intersect(round(src(:,1:2)),[row,col],'rows');
%  src = src(ia,:);
%  srcX = src(:,1);
%  srcY = src(:,2);
%  srcZ = src(:,3);

%  tgtX = tgtX(ia,:);
%  tgtY = tgtY(ia,:);
%  tgtZ = tgtZ(ia,:);

R = eyeImage(:,:,1);
G = eyeImage(:,:,2);
B = eyeImage(:,:,3);

%TODO: do not use values where Z<0

srcX(~isreal(srcX))=0;
srcY(~isreal(srcX))=0;

% calculate bilinear interpolation
RI = interp2(srcX,srcY,R(:),tgtX,tgtY,'bilinear');
GI = interp2(srcX,srcY,G(:),tgtX,tgtY,'bilinear');
BI = interp2(srcX,srcY,B(:),tgtX,tgtY,'bilinear');

s = size(eyeImage);

RI = Reshape(RI,s(1),s(2));
GI = Reshape(GI,s(1),s(2));
BI = Reshape(BI,s(1),s(2));

newim = zeros(size(eyeImage));
newim(:,:,1) = RI;
newim(:,:,2) = GI;
newim(:,:,3) = BI;

