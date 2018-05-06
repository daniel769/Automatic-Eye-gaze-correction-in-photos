function Fixed = completeHoles(eye0, eye1, eyeMask, iris,pupil,dy,dx)
%define 
% retina synthesis for eye completion
if nargin < 1
    load completeHolesData
end
r= size(eye0,1); c= size(eye0,2);
s_halfSam = round(iris(3)/4); %half Iris Radius
samCen.Y =iris(1);
samCen.X =iris(2)-round((iris(3)/2));
%crop retina sample for the texture synthesis
sample(:,:,[1 2 3]) = eye0(samCen.Y-s_halfSam:samCen.Y+s_halfSam,samCen.X-s_halfSam:samCen.X+s_halfSam,:);
mask_idx = find(eyeMask(:,:,1)==1);
[row0,col0] = find(eyeMask(:,:,1)==1);
row1 = row0 + dy;
col1 = col0 + dx;
diff = setdiff([row0,col0], [row1,col1], 'rows');
ind = diff(:,1)+(diff(:,2)-1)*r;

tile_size = 9;
n = uint8(sqrt((size(diff,1)/(tile_size^2)))+1);
%Y = imagequilt(sample, size(sample(:),1), 1);

Texture = imagequilt(sample, tile_size, n);
Fixed = eye1;
Fixed = reshape(eye1, [size(eye1,1)*size(eye1,2) 3]);
Texture = reshape(Texture, [size(Texture,1)*size(Texture,2) 3]);
Fixed(ind',:) = Texture(1:length(ind),:);


%irismask
%1. move center to 0,0.
%2. get coordinates of pixel inside the circle.
%3. translate back to iris center location radius
r = (-5:5);
[X,Y ] = meshgrid(r);
R = (sqrt(X.^2+Y.^2));
[X,Y] = find(R < iris(3));
X = X+iris(2);
Y = Y+iris(1);
%retina sample: diff(eyemask, irismask)


end
