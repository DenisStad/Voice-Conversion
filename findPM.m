function pm = findPM(wav, fs)

pm = [];

[Pitch, numfrms, frmrate] = yaapt(wav, fs);

step = length(wav) / numfrms;
Pitch = interp1(1:step:step*length(Pitch), Pitch, 1:step*length(Pitch));

Pitch(isnan(Pitch)) = 0;


[minPitch, totalpos] = min(Pitch(find(Pitch > 0)));

totalmax = length(wav);
if length(Pitch) < totalmax
    totalmax = length(Pitch);
end

totalposmiddle = totalpos;

while true
    if Pitch(totalpos) ~= 0
        tmppos = totalpos;
        while true
            tmppos = tmppos - 1;
            if tmppos <= 1
                break;
            end
            if Pitch(tmppos) == 0
                break;
            end
        end

        t0voice = tmppos;

        tmppos = totalpos;
        while true
            tmppos = tmppos + 1;
            if tmppos >= totalmax
                break;
            end
            if Pitch(tmppos) == 0
                break;
            end
        end

        tendvoice = tmppos;

        tmiddle = round(t0voice + (tendvoice - t0voice) / 2);
        f0middle = Pitch(tmiddle);

        [windowmax, tmax] = max(wav(round(tmiddle - 0.5 / f0middle * fs):round(tmiddle + 0.5 / f0middle * fs)));
        [windowmin, tmin] = min(wav(round(tmiddle - 0.5 / f0middle * fs):round(tmiddle + 0.5 / f0middle * fs)));
        tpeak = tmax;
        if (-windowmin) > windowmax
            tpeak = tmin;
        end
        tpeak = tpeak + round(tmiddle - 0.5 / f0middle * fs);

        pm = [pm tpeak];

        tmppos = tpeak;
        tpeakmiddle = tpeak; %save for later

        while true

            f0 = Pitch(tmppos);
            t0 = round(tmppos - 1.25 / f0 * fs);
            tend = round(tmppos - 0.8 / f0 * fs);

            if t0 <= 1
                break;
            end
            if t0 <= t0voice
                break;
            end

            frame = wav(t0:tend);

            [windowmax, tmax] = max(frame);
            [windowmin, tmin] = min(frame);
            tpeak = tmax;
            if (-windowmin) > windowmax
                tpeak = tmin;
            end

            tpeak = tpeak + t0;
            pm = [pm tpeak];

            tmppos = tpeak;
        end

        tmppos = tpeakmiddle;

        while true
            f0 = Pitch(tmppos);
            t0 = round(tmppos + 0.8 / f0 * fs);
            tend = round(tmppos + 1.25 / f0 * fs);

            if tend >= totalmax
                break;
            end
            if tend >= tendvoice
                break;
            end

            frame = wav(t0:tend);

            [windowmax, tmax] = max(frame);
            [windowmin, tmin] = min(frame);
            tpeak = tmax;
            if (-windowmin) > windowmax
                tpeak = tmin;
            end

            tpeak = tpeak + t0;
            pm = [pm tpeak];
            tmppos = tpeak;
        end
        
        totalpos = t0voice -1;
    else
        totalpos = totalpos - 0.01 * fs;
        if totalpos > 0
            pm = [pm totalpos];
        end
%         pm = [pm totalpos];
    end
    if totalpos < 1
        break;
    end
end

totalpos = totalposmiddle;

while true
    if Pitch(totalpos) ~= 0
        tmppos = totalpos;
        while true
            tmppos = tmppos - 1;
            if tmppos <= 1
                break;
            end
            if Pitch(tmppos) == 0
                break;
            end
        end

        t0voice = tmppos;

        tmppos = totalpos;
        while true
            tmppos = tmppos + 1;
            if tmppos >= totalmax
                break;
            end
            if Pitch(tmppos) == 0
                break;
            end
        end

        tendvoice = tmppos;

        tmiddle = round(t0voice + (tendvoice - t0voice) / 2);
        f0middle = Pitch(tmiddle);
        
        [windowmax, tmax] = max(wav(round(tmiddle - 0.5 / f0middle * fs):round(tmiddle + 0.5 / f0middle * fs)));
        [windowmin, tmin] = min(wav(round(tmiddle - 0.5 / f0middle * fs):round(tmiddle + 0.5 / f0middle * fs)));
        tpeak = tmax;
        if (-windowmin) > windowmax
            tpeak = tmin;
        end
        tpeak = tpeak + round(tmiddle - 0.5 / f0middle * fs);

        pm = [pm tpeak];

        tmppos = tpeak;
        tpeakmiddle = tpeak; %save for later

        while true

            f0 = Pitch(tmppos);
            t0 = round(tmppos - 1.25 / f0 * fs);
            tend = round(tmppos - 0.8 / f0 * fs);

            if t0 <= 1
                break;
            end
            if t0 <= t0voice
                break;
            end

            frame = wav(t0:tend);

            [windowmax, tmax] = max(frame);
            [windowmin, tmin] = min(frame);
            tpeak = tmax;
            if (-windowmin) > windowmax
                tpeak = tmin;
            end

            tpeak = tpeak + t0;
            pm = [pm tpeak];

            tmppos = tpeak;
        end

        tmppos = tpeakmiddle;

        while true
            f0 = Pitch(tmppos);
            t0 = round(tmppos + 0.8 / f0 * fs);
            tend = round(tmppos + 1.25 / f0 * fs);

            if tend >= totalmax
                break;
            end
            if tend >= tendvoice
                break;
            end

            frame = wav(t0:tend);

            [windowmax, tmax] = max(frame);
            [windowmin, tmin] = min(frame);
            tpeak = tmax;
            if (-windowmin) > windowmax
                tpeak = tmin;
            end

            tpeak = tpeak + t0;
            pm = [pm tpeak];
            tmppos = tpeak;
        end
        
        totalpos = tendvoice +1;
    else
%         totalpos = totalpos +1;
        totalpos = totalpos + 0.01 * fs;
        if totalpos < totalmax
            pm = [pm totalpos];
        end
    end
    if totalpos >= totalmax
        break;
    end
end

pm = sort(pm');



pm = [pm(1); diff(pm)];
pm = pm(find(pm ~= 0));
pm = pm(find(pm ~= 1));
