% Señales de ejemplo
x = [1 2 3];
h = [4 5];

% --- Convolución lineal "real"
y_linear = conv(x, h);

% --- Convolución circular usando DFT sin zero padding
N = length(x); % mismo largo que x
Y_circular = ifft( fft(x, N) .* fft(h, N) );

% --- Convolución lineal usando DFT con zero padding
Npad = length(x) + length(h) - 1; % mínimo para convolución lineal
Y_fft = ifft( fft(x, Npad) .* fft(h, Npad) );

% Mostrar resultados
disp('Convolución lineal (conv):');
disp(y_linear);

disp('Convolución circular (DFT sin padding):');
disp(round(Y_circular, 6));  % redondeo por errores numéricos

disp('Convolución lineal (DFT con zero padding):');
disp(round(Y_fft, 6));
