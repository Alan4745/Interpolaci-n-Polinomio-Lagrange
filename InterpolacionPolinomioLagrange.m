% --- Archivo principal de la aplicación GUI para interpolación con polinomios de Lagrange

function varargout = InterpolacionPolinomioLagrange(varargin)

% Configura que solo se pueda abrir una instancia de la ventana
gui_Singleton = 1;

% Estructura que define los nombres de las funciones de la interfaz
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InterpolacionPolinomioLagrange_OpeningFcn, ...
                   'gui_OutputFcn',  @InterpolacionPolinomioLagrange_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);

% Si se llama la función con un string, se interpreta como nombre de una función callback
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

% Ejecuta la GUI y guarda salidas si se piden
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% --- Función que se ejecuta al abrir la interfaz
function InterpolacionPolinomioLagrange_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Guarda los cambios en la estructura 'handles'
guidata(hObject, handles);

% --- Función que devuelve la salida de la GUI
function varargout = InterpolacionPolinomioLagrange_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Función que se ejecuta al presionar el botón "Calcular"
function btnCalcular_Callback(hObject, eventdata, handles)

try
    % Lee los valores ingresados por el usuario como texto
    x_str = get(handles.inputXn, 'String');   % Coordenadas X
    y_str = get(handles.inputfx, 'String');   % Valores de f(x)
    x_eval_str = get(handles.edit1, 'String');% Punto a evaluar

    % Convierte los textos a números
    x = str2num(x_str); %#ok<ST2NM>
    y = str2num(y_str); %#ok<ST2NM>
    x_eval = str2double(x_eval_str);          % Punto en el cual evaluar el polinomio

    % Verifica que x y y tengan la misma cantidad de elementos
    if length(x) ~= length(y)
        errordlg('La cantidad de valores en x y f(x) debe ser la misma.', 'Error de entrada');
        return;
    end

    n_total = length(x);    % Número total de puntos
    resultado = 0;          % Resultado final de la interpolación
    simbolico = '';         % Variable para armar representación simbólica del polinomio
    texto_resultados = '';  % Texto que mostrará f_n(x) para los primeros grados

    % --- Cálculo del polinomio de Lagrange completo
    for i = 1:n_total
        L = 1;              % Inicializa L_i
        simbolo_Li = '1';   % Para armar representación simbólica de L_i
        for j = 1:n_total
            if i ~= j
                % Se calcula el producto de (x - x_j)/(x_i - x_j)
                L = L * (x_eval - x(j)) / (x(i) - x(j));
                simbolo_Li = [simbolo_Li sprintf(' * (x - %.3f)/(%.3f - %.3f)', x(j), x(i), x(j))];
            end
        end
        resultado = resultado + y(i) * L;
        simbolico = [simbolico sprintf(' + (%.3f)*[%s]', y(i), simbolo_Li)];
    end

    % --- Mostrar resultados intermedios f_2(x_eval), f_3(x_eval), etc.
    max_n = min(n_total, 4); % Solo hasta polinomio de grado 3 (4 puntos)
    for n = 2:max_n
        r = 0;
        for i = 1:n
            L = 1;
            for j = 1:n
                if i ~= j
                    L = L * (x_eval - x(j)) / (x(i) - x(j));
                end
            end
            r = r + y(i) * L;
        end
        % Agrega línea de resultado parcial al texto
        texto_resultados = [texto_resultados sprintf('f_%d(%.3f) = %.6f\n', n, x_eval, r)];
    end

    % Muestra resultados intermedios en el cuadro de texto de la interfaz
    set(handles.lblResultados, 'String', texto_resultados);

    % Prepara valores para graficar el polinomio
    xx = linspace(min(x), max(x), 300); % Vector de puntos para graficar
    yy = zeros(size(xx));               % Inicializa el vector de resultados

    % Calcula los valores del polinomio para todos los puntos xx
    for k = 1:length(xx)
        for i = 1:n_total
            L = 1;
            for j = 1:n_total
                if i ~= j
                    L = L * (xx(k) - x(j)) / (x(i) - x(j));
                end
            end
            yy(k) = yy(k) + y(i) * L;
        end
    end

    % --- Mostrar la gráfica
    figure;
    plot(x, y, 'ro', 'MarkerSize', 8, 'DisplayName', 'Puntos dados'); % Puntos originales
    hold on;
    plot(xx, yy, 'b-', 'LineWidth', 2, 'DisplayName', 'Interpolación de Lagrange'); % Polinomio
    plot(x_eval, resultado, 'ks', 'MarkerSize', 10, 'DisplayName', 'Punto evaluado'); % Punto evaluado
    legend('show');
    grid on;
    title('Interpolación de Lagrange');
    xlabel('x');
    ylabel('f(x)');

catch ME
    % Muestra un mensaje si hay un error
    errordlg(['Error al calcular: ' ME.message], 'Error');
end

% --- Estas funciones son requeridas por MATLAB pero no tienen lógica personalizada
function inputXn_Callback(hObject, eventdata, handles)
function inputfx_Callback(hObject, eventdata, handles)
function edit1_Callback(hObject, eventdata, handles)

% --- Establecen el color de fondo blanco en los cuadros de texto
function inputXn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function inputfx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
