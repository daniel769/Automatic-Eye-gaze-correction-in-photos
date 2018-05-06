addpath('Texture_Synthesis_Using_Image_Quilting');
addpath('Integrodifferential operator');
addpath('images');
addpath('fdlibmex\pcwin');

%imfilename = 'clb1.jpg';
%imfilename = 'angelina_jolie.jpg';
imfilename = 'frontal_view_model.jpg';
Im = imread(imfilename);
 newim = GazeCorrect(Im);