* LIF (Leaky Integrate-and-Fire) Neuron Model based on Carver Mead's approach
* Using TSMC 180nm Technology
* 
* LIF (Leaky Integrate-and-Fire) Neuron Model based on Carver Mead's approach
* Using TSMC 180nm Technology
* 
* This implementation uses subthreshold operation as advocated by Mead
* with components that would be available in a standard CMOS process

* Include TSMC 180nm model file (you'll need to provide this path)
.include tsmc_180nm.txt
* Supply voltages
Vdd vdd 0 DC 1.8
Vss vss 0 DC 0

* Global parameters
.param Vth=0.8       ; Threshold voltage for firing
.param Vreset=0.2     ; Reset voltage after spike
.param Ileak=50p      ; Leakage current (controls tau_m)
.param Iinject=200p   ; Input current stimulus

* Membrane capacitor (implements the integration)
Cmem membrane 0 1p

* Input current source (stimulus)
Iin 0 membrane DC 200p

* Leak transistor (implements the "leak" in LIF)
* Using PMOS in subthreshold region as recommended by Mead
Mleak membrane leak_bias vdd vdd cmosp W=5u L=1u
Vleak leak_bias 0 DC 1.2  ; Fixed value for bias voltage

* Threshold detection using a voltage-controlled switch
* This replaces the behavioral source with a more compatible construct
Rthres membrane spike_trig 10Meg
Cthres spike_trig 0 1p
Sthres spike_trig 0 membrane vss sthres_model
.model sthres_model sw vt={Vth} vh=0.01 ron=100 roff=10Meg

* Spike output generation
Rspike spike_trig spike_out 100k
Cspike spike_out 0 10p
Vsp_high sp_high 0 DC 1.8
Ssp_out spike_out sp_high spike_trig 0 sspike_model
.model sspike_model sw vt=0.9 vh=0.01 ron=100 roff=10Meg

* Reset circuit activated by threshold crossing
* Using voltage-controlled switches instead of behavioral sources
Sreset membrane reset_node spike_trig 0 sreset_model
.model sreset_model sw vt=0.9 vh=0.01 ron=100 roff=10Meg
Vreset reset_node 0 DC 0.2

* Transient analysis
.tran 0.01m 100m uic

* Analysis settings
.option post=1
.option precise
.option method=gear

* Plotting commands
.control
run
plot v(membrane) v(spike_out)*0.2+0.8
.endc
.end
