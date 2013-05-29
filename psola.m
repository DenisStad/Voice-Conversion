function wav = psola(frames, f0factor)

currentNewPos = 1;
currentOrigPos = 0;
posDiff = 0;

for i = 1:length(frames)-2
    wavPart1 = frames(i).data;
    wavPart2 = frames(i+1).data;
    origLength = length(wavPart1) + length(wavPart2);
    newLength = round(origLength * f0factor);
    if f0factor > 1.0
        if currentOrigPos+newLength>=currentNewPos;
            i=i+1;
            wavPart2 = frames(i+1).data;
            origLength = length(wavPart1) + length(wavPart2);
            newLength = round(origLength * f0factor);
        end
    end
    currentNewPos = currentNewPos+round(length(wavPart1)*f0factor);
    posDiff = posDiff + abs(newLength - origLength);
    currentOrigPos = currentOrigPos + origLength;
    if f0factor < 1.0
        if posDiff>=newLength
            currentNewPos = currentNewPos+round(length(wavPart1)*f0factor);
            posDiff = posDiff + abs(newLength - origLength) - newLength;
        end
    end
end

outWav = zeros(currentNewPos + origLength + newLength,1);
currentNewPos = 1;
currentOrigPos = 0;
posDiff = 0;

for i = 1:length(frames)-2
    
    wavPart1 = frames(i).data;
    wavPart2 = frames(i+1).data;
    
    origLength = length(wavPart1) + length(wavPart2);
    newLength = round(origLength * f0factor);
    
    if f0factor > 1.0
        if currentOrigPos+newLength>=currentNewPos;
            i=i+1;
            wavPart2 = frames(i+1).data;
            origLength = length(wavPart1) + length(wavPart2);
            newLength = round(origLength * f0factor);
        end
    end
    
    han = hanning(newLength);
    
    outWav(currentNewPos:currentNewPos+length(han)-1) = outWav(currentNewPos:currentNewPos+length(han)-1)+interp1(1:origLength,[wavPart1; wavPart2],1:newLength,'linear','extrap')'.*han;
    currentNewPos = currentNewPos+round(length(wavPart1)*f0factor);
    
    posDiff = posDiff + abs(newLength - origLength);
    currentOrigPos = currentOrigPos + origLength;
    
    if f0factor < 1.0
        if posDiff>=newLength
            outWav(currentNewPos:currentNewPos+length(han)-1) = outWav(currentNewPos:currentNewPos+length(han)-1)+interp1(1:origLength,[wavPart1; wavPart2],1:newLength)'.*han;
            currentNewPos = currentNewPos+round(length(wavPart1)*f0factor);
            posDiff = posDiff + abs(newLength - origLength) - newLength;
        end
    end
end

wav = outWav;
