* LIF (Leaky Integrate-and-Fire) Neuron Implementation based on provided schematic
* Using TSMC 180nm Technology with cmosn and cmosp models

* Include TSMC 180nm model file
.include "tsmc_180nm.txt"

* Supply voltages
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0

* Global parameters
.param Vth=0.8      ; Threshold voltage 
.param Vreset=0.2    ; Reset voltage
.param Ileak=50p     ; Leakage current
.param Iex=200p      ; External input current
.param Cm_val=1p     ; Membrane capacitance

* Stimuli for control signals
Vclk clk 0 PULSE(0 1.8 10m 1n 1n 5m 20m)    ; Clock signal
Vth_bias vth 0 DC {Vth}                     ; Threshold bias voltage

* Membrane capacitor
Cm vm 0 {Cm_val}

* Current sources - external input and leakage
Iex vm 0 DC {Iex}    ; External input current (note: direction reversed from schematic for SPICE convention)
Ileak 0 vm DC {Ileak} ; Leakage current

* Switch SW1 implementation (PMOS)
M_SW1 vm vdd vdd vdd cmosp W=5u L=0.18u  ; Always ON for charging

* Switch SW2 implementation (NMOS for reset)
M_SW2 vm reset 0 0 cmosn W=5u L=0.18u
Vreset reset 0 PULSE(0 1.8 0 1n 1n 1m 100m) ; Periodic reset pulse

* Switch SW3 implementation (NMOS controlled by CLK)
M_SW3 n5 clk 0 0 cmosn W=1u L=0.18u

* Inverter chain for threshold detection and spike generation
* First inverter
M1 n1 vm vdd vdd cmosp W=2u L=0.18u
M2 n1 vm 0 0 cmosn W=1u L=0.18u

* Second inverter
M3 n2 n1 vdd vdd cmosp W=4u L=0.18u
M4 n2 n1 0 0 cmosn W=2u L=0.18u

* Third inverter
M5 n3 n2 vdd vdd cmosp W=8u L=0.18u
M6 n3 n2 0 0 cmosn W=4u L=0.18u

* Output stage
M7 output clk vdd vdd cmosp W=10u L=0.18u
M6_out n3 n5 output 0 cmosn W=8u L=0.18u

* Transient analysis
.tran 0.01m 100m

* Analysis settings
.option post=1
.option precise
.option method=gear

* Plotting commands
.control
run
plot v(vm) v(output)*0.2+0.8
plot v(vm) v(output)
plot v(clk) v(reset)
.endc
.end
