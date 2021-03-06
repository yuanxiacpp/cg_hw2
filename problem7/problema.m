fid = fopen('dir_files');

tline = fgets(fid);
while ischar(tline)
    image_dir = strcat('resized_image', tline);
    disp(image_dir);
    disp('1) Read a stack of LDR images');
    stack = ReadLDRStack(image_dir, 'jpg')/255.0;
    
    disp('2) Align the stack');
    [alignment, stackOut] = WardAlignment(stack, 1, '','');
    clear('stack');
    
    disp('3) Read exposure values from the exif');
    stack_exposure = ReadLDRExif(image_dir, 'jpg');
    
    disp('4) Build the radiance map using the stack and stack_exposure');
    for lamda=5:5:50
        %disp(lamda););
        
        out = textscan(tline, '%s', 'delimiter', '/');
        [x, y] = size(out{1});
        
        name = strcat('problema_output/', out{1}{x}, '/lamda-', num2str(lamda));
        hdrFile = strcat(name, '.hdr');
        jpgFile = strcat(name, '.jpg');
        
        imgHDR = myBuildHDR([], [], 'tabledDeb97', 'Gauss', stackOut, stack_exposure, lamda, jpgFile);
        
        %disp('5) Save radiance map in the .hdr format');
        %hdrimwrite(imgHDR, hdrFile);
        
        
        %pngFile = strcat(name, '.png');
        %imgTMO = ReinhardTMO(imgHDR);
        %imwrite(GammaTMO(imgHDR, 2.2, 0, 0), pngFile);
        
        %disp('6) Show the tone mapped version of the radiance map');
        %h = figure(1);
        %set(h, 'Name', 'Tone mapped built HDR Image');
        %yGammaTMO(ReinhardBilTMO(imgHDR), 2.2, 0, 1);
        
    end
    
    
    
    tline = fgets(fid);
end



