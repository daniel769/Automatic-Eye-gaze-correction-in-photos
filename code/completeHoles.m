function fixed_eye = completeHoles(eye_orig, eye_transformed, eye_mask, eye_mask_trans, iris, iris_trans)
%define 
% retina synthesis for eye completion

r= size(eye_orig,1); c= size(eye_orig,2);

% find original iris coordinates
[X,Y] = meshgrid(1:c,1:r);
circle_orig = (X-iris.x0).^2 + (Y-iris.y0).^2 - (iris.r^2);
[r_iris_orig , c_iris_orig] = find(circle_orig <= 0);

% find translated iris coordinates
[X,Y] = meshgrid(1:c,1:r);
circle_trans = (X-iris_trans.x0).^2 + (Y-iris_trans.y0).^2 - (iris_trans.r^2);
[r_iris_trans , c_iris_trans] = find(circle_trans <= 0);

%crop iris sample for the texture synthesis
samp_size = round(iris.r/2); %half Iris Radius
sample.x0 =round(iris.x0 - iris.r/2 - 0.5*samp_size); %sampling center is minus half the iris radius
sample.y0 =round(iris.y0 - 0.5*samp_size);
iris_sample_rect = [sample.x0, sample.y0, samp_size, samp_size];
iris_sample(:,:,[1 2 3]) = imcrop(eye_orig, iris_sample_rect);

%find original sclera region
[r_eye_orig , c_eye_orig] = find(eye_mask(:,:,1)==1);
sclera_diff_orig = setdiff([r_eye_orig , c_eye_orig], [r_iris_orig , c_iris_orig], 'rows');
sclera_orig = sclera_diff_orig(:,1)+(sclera_diff_orig(:,2)-1)*r;

sclera_pixels = zeros(size(sclera_orig,1),3);
sclera_pixels(:,1) = eye_orig(sclera_orig);
sclera_pixels(:,2) = eye_orig(sclera_orig+r*c);
sclera_pixels(:,3) = eye_orig(sclera_orig + r*c*2);
vec_size = size(sclera_pixels,1);


square_size = uint32(sqrt(vec_size));
sclera_sample = reshape(sclera_pixels(1:square_size^2,:),square_size,square_size,3);


% find region to be filled (includes both sclera and iris)
[r_eye_trans , c_eye_trans] = find(eye_mask_trans(:,:,1)==1);
diff = setdiff([r_eye_orig , c_eye_orig], [r_eye_trans , c_eye_trans], 'rows');

% find region to be filled with iris color
iris_isec = intersect(diff,[r_iris_trans , c_iris_trans],'rows');
%find region to be filled with sclera color
sclera_diff = setdiff(diff,[r_iris_trans , c_iris_trans],'rows');

fixed_eye = fill_missing_part(eye_transformed, iris_isec, iris_sample);
fixed_eye = fill_missing_part(fixed_eye, sclera_diff, sclera_sample);

function [filled_image] = fill_missing_part(eye_image, region_pixels, sample)
r = size(eye_image,1);
tile_size = size(sample,1)-1;
% synthesize iris texture from iris seed
n = uint8(sqrt((size(region_pixels,1)/(tile_size^2)))+1);
texture = imagequilt(sample, tile_size, n);
% apply iris texture to iris missing region
pixels_to_fill = region_pixels(:,1)+(region_pixels(:,2)-1)*r;

% apply texture to the missing region
filled_image = reshape(eye_image, [size(eye_image,1)*size(eye_image,2) 3]);
texture = reshape(texture, [size(texture,1)*size(texture,2) 3]);
filled_image(pixels_to_fill',:) = texture(1:length(pixels_to_fill),:);
filled_image = reshape(filled_image, [size(eye_image,1),size(eye_image,2),3]);
