#LIBRERIAS UTILIZADAS
import numpy as np
import matplotlib.pyplot as plt
#from scipy.signal import spectrogram
import adi
#----------------------------- FUNCIONES ------------------------------------------------------------
def generate_chirp(simbolo, sf, Bw, time_interval, samples):

  M = 2**sf
  Ts = M/np.abs(Bw)      
  wf_f = []

  for i in range(samples):
    wf_f.append((simbolo*np.abs(Bw)/M + Bw/Ts*time_interval[i]) % np.abs(Bw)) 

  return wf_f  

def generate_symbols(sf, n_data, Bw, samples, ):
        
  data = []
  chirps = np.array([])
  Ts =  2**sf/Bw #Tiempo de simbolo   
  t_c = np.linspace(0, Ts, samples)

  for i in range(n_data):
    data.append(np.random.randint(0, 2**sf))
    chirps = np.append(chirps, generate_chirp(data[i], sf, Bw, t_c, samples))

  return np.array(data), chirps

def plot_waveform(ax, t, wf, axis_x_label, axis_y_label, title, Ts, len_packet_tx):
            
  ax.set_facecolor('black')
  ax.set_title(title, fontdict={'color':'white','weight':'bold','size' : 20}, pad = 20)
  ax.set_xlabel(axis_x_label, fontdict={'color':'white','weight':'bold','size' : 20}, labelpad = 10)
  ax.set_ylabel(axis_y_label, fontdict={'color':'white','weight':'bold','size' : 20}, labelpad = 5)
  ax.tick_params(axis='both', which='major', labelsize=10, colors='white')
  ax.set_xticks(np.arange(0, len_packet_tx, Ts))
  ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.3f'))
  ax.plot(t, wf, lw=2)   
  ax.grid()    

#------------------------------- SDR Parameter Configuration -------------------------------

#------------------------------- SDR Setup ------------------------------- 

sdr             = adi.Pluto("ip:192.168.2.1")
sdr.sample_rate = 2e6
sdr.loopback    = 0
#Tx:
sdr.tx_lo                 = int(1_200_000_000)
sdr.tx_hardwaregain_chan0 = -10 
sdr.tx_rf_bandwidth       = 4_000_000
sdr.tx_cyclic_buffer      = True
# Rx:
sdr.rx_lo                   = int(1_200_000_000)
sdr.gain_control_mode_chan0 = "slow_attack"
sdr.rx_rf_bandwidth         = int(4_000_000)
sdr.rx_cyclic_buffer        = False
sdr.rx_buffer_size          = 2**20-1

#------------------------------ MAIN --------------------------------------------------------------------------
sf = 7 #Spreading factor
Bw = 125 #Khz
Ts = 2**sf/Bw #Tiempo de simbolo
n_data = 1 # numero de datos a transmitir
spc = 1  # samples per 1/B 
sps = int(2**sf * spc) #samples = int(2**sf*1/delta) # samples per symbol 
variance= 0.13

#symbs, data_tx_f  = generate_symbols(sf, n_data, Bw, sps) # symbs son los datos generados aleatoriamente, data_tx son los crirp en frecuencia
t_c = np.linspace(0, Ts, sps)
symb = 50
data_tx_f = generate_chirp(symb, sf, Bw, t_c, sps)

print("Simbolo transmitido", symb)
# Grafico Frecuencia vs tiempo
fig1, ax1 = plt.subplots(1, figsize = (20, 5))    
fig1.patch.set_facecolor('black')

t = np.linspace(0, Ts, sps)

# Grafico Frecuencia vs tiempo
plot_waveform(ax1, t, data_tx_f, "Time [ms]", "Frequency [Khz]", "LoRa Modulation", Ts, sps)

#------------------------------- Transmitter ------------------------------- 

sdr.tx(data_tx_f*2**14)
