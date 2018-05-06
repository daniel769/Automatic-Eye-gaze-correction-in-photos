%function Y = imagequilt(X, tilesize, n, overlap, err)
%    Performs the Efros/Freeman Image quilting algorithm on the input
%
%Inputs
%   X:  The source image to be used in synthesis
%   tilesize:   the dimensions of each square tile.  Should divide size(X) evenly
%   n:  The number of tiles to be placed in the output image, in each dimension
%   overlap: The amount of overlap to allow between pixels (def: 1/6 tilesize)
%   err: used when computing list of compatible tiles (def: 0.1)

function Y = imagequilt(X, tilesize, n, overlap, err)
if nargin < 1
X = imread('weave.jpg');
end
if nargin < 2
tilesize = 36;
end
if nargin < 3
n = 5; 
end
if nargin < 4
    overlap = round(tilesize/6);
end
if nargin < 5
    err = 0.002;
end

X = double(X);
simple = 0;

destsize = n * tilesize - (n-1) * overlap;
Y = zeros(destsize, destsize, 3);
for i=1:n
    for j=1:n
        startI = (i-1)*tilesize - (i-1) * overlap + 1;
        startJ = (j-1)*tilesize - (j-1) * overlap + 1;
        endI = startI + tilesize -1;
        endJ = startJ + tilesize -1;
        % Determine the distances from each tile to the overlap region
        % This will eventually be replaced with convolutions
        distances = zeros( size(X,1)-tilesize, size(X,2)-tilesize );
        %Compute the distances from the source to the left overlap region
        if( j > 1 )
            distances = ssd( X, Y(startI:endI, startJ:startJ+overlap-1, 1:3) );
            distances = distances(1:end, 1:end-tilesize+overlap);
        end;
        
        % Compute the distance from the source to top overlap region
        if( i > 1 )
            Z = ssd( X, Y(startI:startI+overlap-1, startJ:endJ, 1:3) );
            Z = Z(1:end-tilesize+overlap, 1:end);
            if( j > 1 )
                distances = distances + Z;
            else
                distances = Z;
            end;
        end;

        % If both are greater, compute the distance of the overlap
        if( i > 1 && j > 1 )
            Z = ssd( X, Y(startI:startI+overlap-1, startJ:startJ+overlap-1, 1:3) );
            Z = Z(1:end-tilesize+overlap, 1:end-tilesize+overlap);
            distances = distances - Z;
        end;

        % distances = distances(1:end-tilesize, 1:end-tilesize);



        % Find the best candidates for the match
        best = min(distances(:));
        candidates = find(distances(:) <= (1+err)*best);

        idx = candidates(ceil(rand(1)*length(candidates)));

        [sub(1), sub(2)] = ind2sub(size(distances), idx);
        fprintf( 'Picked tile (%d, %d) out of %d candidates.  Best error=%.4f\n', sub(1), sub(2), length(candidates), best );

        % If we do the simple quilting (no cut), just copy image
        if( simple )
            Y(startI:endI, startJ:endJ, 1:3) = X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, 1:3);
        else

            %Initialize the mask to all ones
            M = ones(tilesize, tilesize);

            %We have a left overlap
            if( j > 1 )

                %Compute the SSD in the border region
                E = ( X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+overlap-1) - Y(startI:endI, startJ:startJ+overlap-1) ).^2;

                %Compute the mincut array
                C = mincut(E, 0);

                %Compute the mask and write to the destination
                M(1:end, 1:overlap) = double(C >= 0);
                %Y(startI:endI, startJ:endJ, :) = filtered_write(Y(startI:endI, startJ:endJ, :), ...
                %    X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :), M);

                %Y(startI:endI, startJ:endJ, 1:3) = X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, 1:3);

                %Compute the mask and write to the destination
                %                  M = zeros(tilesize, tilesize);
                %                  M(1:end, 1:overlap) = double(C == 0);
                %                  Y(startI:endI, startJ:endJ, :) = filtered_write(Y(startI:endI, startJ:endJ, :), ...
                %                      repmat(255, [tilesize, tilesize, 3]), M);

            end;

            %We have a top overlap
            if( i > 1 )
                %Compute the SSD in the border region
                E = ( X(sub(1):sub(1)+overlap-1, sub(2):sub(2)+tilesize-1) - Y(startI:startI+overlap-1, startJ:endJ) ).^2;

                %Compute the mincut array
                C = mincut(E, 1);

                %Compute the mask and write to the destination
                M(1:overlap, 1:end) = M(1:overlap, 1:end) .* double(C >= 0);
                %Y(startI:endI, startJ:endJ, :) = filtered_write(Y(startI:endI, startJ:endJ, :), ...
                %    X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :), M);
            end;


            if( i == 1 && j == 1 )
                Y(startI:endI, startJ:endJ, 1:3) = X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, 1:3);
            else
                %Write to the destination using the mask
                Y(startI:endI, startJ:endJ, :) = filtered_write(Y(startI:endI, startJ:endJ, :), ...
                    X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :), M);
            end;

        end;


        image(uint8(Y));
        drawnow;
    end;
end;

figure;
image(uint8(Y));

