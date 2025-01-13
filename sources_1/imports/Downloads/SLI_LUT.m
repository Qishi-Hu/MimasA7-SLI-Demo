% Generate the LUT values
lut = 0.5 + 0.5 * cos(2*pi*(0:719)/720);
disp(lut(1:30));
% Scale the values to integers between 0 and 255
lut_scaled = uint8(255 * lut);
disp(lut_scaled(1:30));
% Write the array to a raw binary file
fid = fopen('LUT.raw', 'wb');
fwrite(fid, lut_scaled, 'uint8');
fclose(fid);
clear;