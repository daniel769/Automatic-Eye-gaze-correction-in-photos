function A = filtered_write(A, B, M)
for i = 1:3,
    A(:, :, i) = A(:,:,i) .* (M == 0) + B(:,:,i) .* (M == 1);
end;
