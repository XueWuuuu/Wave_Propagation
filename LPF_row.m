function zout = LPF_row(data, tt, fp, fs, Rp, Rs)
% Rp = 6; % Rs = 30; % fp = 20e6; % fs = 22e6;
flag = 0;
if size(tt,2)<size(tt,1)
    data = data';
    tt = tt';
    flag = 1;
end
L = length(tt);
Fs = 1/abs(tt(2)-tt(1));
%NFFT=2^nextpow2(L); 
NFFT=L;
if mod(NFFT,2)
%     fprintf('LPF_row: filter maybe error with an odd siginal number!')
    f=Fs/2*linspace(0,1,NFFT/2+1);
    Y=fft(data,NFFT,2)/L; 
    [N,Wn]=buttord(fp,fs,Rp,Rs,'s');
    [bb,ab]=butter(N,Wn,'s');
    [Hb,wb]=freqs(bb,ab,f); 
    Hb = diag(Hb); 
    ff = floor(NFFT/2)+1;
    A=2*abs(Y(:,1:ff))*(abs(Hb));
    fl = floor(L-(NFFT/2))+1;
    for i=1:fl-1
    A(:,(fl+i))=A(:,(fl-i));
    end
else
    f=Fs/2*linspace(0,1,NFFT/2);
    Y=fft(data,NFFT,2)/L; 
    [N,Wn]=buttord(fp,fs,Rp,Rs,'s');
    [bb,ab]=butter(N,Wn,'s');
    [Hb,wb]=freqs(bb,ab,f); 
    Hb = diag(Hb); 
    A=2*abs(Y(:,1:NFFT/2))*(abs(Hb));
    fl = floor(NFFT/2+1);
    for i=1:L-fl
    A(:,(fl+i))=A(:,(fl-i));
    end
end
z=A.*exp(1i*angle(Y));
z2=real(ifft(z,[],2));
zout = z2*NFFT/2;

end