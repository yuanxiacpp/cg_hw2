function imgHDR = BuildHDR(dir_name, format, lin_type, weightFun, stack, stack_exposure)
%
%       imgHDR = BuildHDR(dir_name, format, lin_type, weightFun, stack, stack_exposure)
%
%
%        Input:
%           -dir_name: the folder name where the stack is stored as a
%           series of LDR images.
%           -format: an LDR format for reading LDR images in dir_name
%           -lin_type: the linearization function:
%                      - 'linearized': images are already linearized
%                      - 'gamma2.2': gamma function 2.2 is used for
%                                    linearisation;
%                      - 'function': a spline for RGB is used for 
%                                    linearisation passed as input in
%                                    lin_fun
%                      - 'tabledDeb97': a tabled RGB function is used for
%                                       linearisation passed as input in
%                                       lin_fun using Debevec and Malik 97
%                                       method
%           -weight_type:
%               - 'all':   weight is set to 1
%               - 'hat':   hat function 1-(2x-1)^12
%               - 'Deb97': Debevec and Malik 97 weight function
%               - 'Gauss': Gaussian function as weight function.
%                          This function produces good results when some 
%                          under-exposed or over-exposed images are present
%                          in the stack.
%           -stack: a stack of LDR images; 4-D array where values are
%           -stack_exposure: exposure values of the stack in seconds
%
%        Output:
%           -imgHDR: the final HDR image
%
%     Copyright (C) 2011  Francesco Banterle
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

%is a weight function defined?
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

        for i=1:nCol
            g = gsolve(stack_samples(:,:,i),log_stack_exposure,10,W);
            lin_fun(:,i) = (g/max(g));
        end
        
    otherwise    
end

%Combine different exposure using linearization function
imgHDR = CombineLDR(stack, stack_exposure, lin_type, lin_fun, weightFun);

end