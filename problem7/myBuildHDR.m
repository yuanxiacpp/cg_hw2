function imgHDR = myBuildHDR(dir_name, format, lin_type, weightFun, stack, stack_exposure, lamda,jpgFile)
    if(~exist('weightFun','var'))
        weightFun = 'all';
    end

    %is the linearization type of the images defined?
    if(~exist('lin_type','var'))
        lin_type = 'gamma2.2';
    end

    if(~exist('stack','var')&&~exist('stack_exposure','var'))
        %Read images from the current directory
        stack = ReadLDRStack(dir_name, format);
        stack_exposure = ReadLDRExif(dir_name, format);
    else
        maxStack = max(stack(:));
        if(maxStack<=(1.0+1e-9))
            stack = ClampImg(round(stack * 255),0,255);
        end   
    end

    lin_fun = [];
    switch lin_type
        case 'tabledDeb97' %Estimating the CRF using Debevec and Malik
            %Weight function
            W = WeightFunction(0:(1/255):1,'Deb97');
            %Convert the stack into a smaller stack
            stack_hist = ComputeLDRStackHistogram(stack);
            stack_samples = GrossbergSampling('', '', stack_hist, 100);%StackLowRes(stack);
            %Linearization process using Debevec and Malik 1998's method
            [nPixel, nStack, nCol] = size(stack_samples);

            lin_fun = zeros(256,nCol);
            log_stack_exposure = log(stack_exposure);

            h = figure;
            for i=1:nCol
                g = gsolve(stack_samples(:,:,i),log_stack_exposure,lamda,W);
                hold on;
                plot(g);                
                lin_fun(:,i) = (g/max(g));
            end
            saveas(h, jpgFile, 'jpg');

        otherwise    
    end

    %Combine different exposure using linearization function
    imgHDR = CombineLDR(stack, stack_exposure, lin_type, lin_fun, weightFun);
end
