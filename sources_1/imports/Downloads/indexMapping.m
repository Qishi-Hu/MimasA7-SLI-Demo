%15-bit indexMapping ROM
% [9:0] is for row index, [12:10] is for frame index. 
% [14:13] is for frquency index
% i is the index/address of the map, 
% j is the corresponding index in the input LUT
Map = zeros(32768,1);
for frq = 0:2
    if frq == 2 
        offset = 30;
    elseif frq == 1
        offset = 6;
    else 
        offset = 1;
    end
    for frm = 0:7
        shift = frm * 720 /8;    
        for row = 0:719    
            i= frq*8192 + frm*1024 + row;
            j = rem((shift + offset * row),720); 
            Map(i+1)=j; 
        end
    end
end
% Creat the coefficient (COE) file of the ROM
fileID = fopen('indexMap.coe', 'w');
fprintf(fileID, 'memory_initialization_radix=2;\n');
fprintf(fileID, 'memory_initialization_vector=\n');

% Write each element in binary format, ensuring 10 bits
for idx = 1:32768
    binaryValue = dec2bin(Map(idx), 10);
    fprintf(fileID, '%s', binaryValue); 
    if idx < 32768
        fprintf(fileID, ',\n');
    else
        fprintf(fileID, ';\n');
    end
end
fclose(fileID);
fprintf('COE file successfully created \n');
clear;