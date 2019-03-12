#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Receive And Track
# Generated: Mon Mar 11 17:33:47 2019
##################################################

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print "Warning: failed to XInitThreads()"

from PyQt4 import Qt
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio import qtgui
from gnuradio.eng_option import eng_option
from gnuradio.fft import logpwrfft
from gnuradio.filter import firdes
from optparse import OptionParser
import osmosdr
import sip
import sys
import time


class receive_and_track(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Receive And Track")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Receive And Track")
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "receive_and_track")
        self.restoreGeometry(self.settings.value("geometry").toByteArray())

        ##################################################
        # Variables
        ##################################################
        self.sdr_samp = sdr_samp = 1.8e6
        self.samp_rate = samp_rate = 40e3
        self.fft_size = fft_size = 1024
        self.center_freq = center_freq = 430e6 - 9e3

        ##################################################
        # Blocks
        ##################################################
        self.rational_resampler_xxx_0 = filter.rational_resampler_ccc(
                interpolation=1,
                decimation=int(1.8e6/40e3),
                taps=None,
                fractional_bw=None,
        )
        self.qtgui_sink_x_0 = qtgui.sink_c(
        	fft_size, #fftsize
        	firdes.WIN_BLACKMAN_hARRIS, #wintype
        	center_freq, #fc
        	samp_rate, #bw
        	"", #name
        	True, #plotfreq
        	True, #plotwaterfall
        	True, #plottime
        	True, #plotconst
        )
        self.qtgui_sink_x_0.set_update_time(1.0/10)
        self._qtgui_sink_x_0_win = sip.wrapinstance(self.qtgui_sink_x_0.pyqwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._qtgui_sink_x_0_win)
        
        self.qtgui_sink_x_0.enable_rf_freq(True)
        
        
          
        self.qtgui_number_sink_0 = qtgui.number_sink(
            gr.sizeof_float,
            0,
            qtgui.NUM_GRAPH_HORIZ,
            1
        )
        self.qtgui_number_sink_0.set_update_time(0.10)
        self.qtgui_number_sink_0.set_title("")
        
        labels = ["", "", "", "", "",
                  "", "", "", "", ""]
        units = ["", "", "", "", "",
                 "", "", "", "", ""]
        colors = [("black", "black"), ("black", "black"), ("black", "black"), ("black", "black"), ("black", "black"),
                  ("black", "black"), ("black", "black"), ("black", "black"), ("black", "black"), ("black", "black")]
        factor = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        for i in xrange(1):
            self.qtgui_number_sink_0.set_min(i, -1)
            self.qtgui_number_sink_0.set_max(i, 1)
            self.qtgui_number_sink_0.set_color(i, colors[i][0], colors[i][1])
            if len(labels[i]) == 0:
                self.qtgui_number_sink_0.set_label(i, "Data {0}".format(i))
            else:
                self.qtgui_number_sink_0.set_label(i, labels[i])
            self.qtgui_number_sink_0.set_unit(i, units[i])
            self.qtgui_number_sink_0.set_factor(i, factor[i])
        
        self.qtgui_number_sink_0.enable_autoscale(False)
        self._qtgui_number_sink_0_win = sip.wrapinstance(self.qtgui_number_sink_0.pyqwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._qtgui_number_sink_0_win)
        self.logpwrfft_x_0 = logpwrfft.logpwrfft_c(
        	sample_rate=samp_rate,
        	fft_size=fft_size,
        	ref_scale=2,
        	frame_rate=30,
        	avg_alpha=1.0,
        	average=False,
        )
        self.blocks_short_to_float_0 = blocks.short_to_float(1, float(fft_size/samp_rate))
        self.blocks_null_sink_0 = blocks.null_sink(gr.sizeof_short*1)
        self.blocks_argmax_xx_0 = blocks.argmax_fs(fft_size)
        self.NANO_SDR = osmosdr.source( args="numchan=" + str(1) + " " + "rtl=0" )
        self.NANO_SDR.set_time_unknown_pps(osmosdr.time_spec_t())
        self.NANO_SDR.set_sample_rate(sdr_samp)
        self.NANO_SDR.set_center_freq(center_freq, 0)
        self.NANO_SDR.set_freq_corr(0, 0)
        self.NANO_SDR.set_dc_offset_mode(0, 0)
        self.NANO_SDR.set_iq_balance_mode(0, 0)
        self.NANO_SDR.set_gain_mode(False, 0)
        self.NANO_SDR.set_gain(10, 0)
        self.NANO_SDR.set_if_gain(10, 0)
        self.NANO_SDR.set_bb_gain(10, 0)
        self.NANO_SDR.set_antenna("", 0)
        self.NANO_SDR.set_bandwidth(0, 0)
          

        ##################################################
        # Connections
        ##################################################
        self.connect((self.NANO_SDR, 0), (self.rational_resampler_xxx_0, 0))    
        self.connect((self.blocks_argmax_xx_0, 1), (self.blocks_null_sink_0, 0))    
        self.connect((self.blocks_argmax_xx_0, 0), (self.blocks_short_to_float_0, 0))    
        self.connect((self.blocks_short_to_float_0, 0), (self.qtgui_number_sink_0, 0))    
        self.connect((self.logpwrfft_x_0, 0), (self.blocks_argmax_xx_0, 0))    
        self.connect((self.rational_resampler_xxx_0, 0), (self.logpwrfft_x_0, 0))    
        self.connect((self.rational_resampler_xxx_0, 0), (self.qtgui_sink_x_0, 0))    

    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "receive_and_track")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()


    def get_sdr_samp(self):
        return self.sdr_samp

    def set_sdr_samp(self, sdr_samp):
        self.sdr_samp = sdr_samp
        self.NANO_SDR.set_sample_rate(self.sdr_samp)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_short_to_float_0.set_scale(float(self.fft_size/self.samp_rate))
        self.logpwrfft_x_0.set_sample_rate(self.samp_rate)
        self.qtgui_sink_x_0.set_frequency_range(self.center_freq, self.samp_rate)

    def get_fft_size(self):
        return self.fft_size

    def set_fft_size(self, fft_size):
        self.fft_size = fft_size
        self.blocks_short_to_float_0.set_scale(float(self.fft_size/self.samp_rate))

    def get_center_freq(self):
        return self.center_freq

    def set_center_freq(self, center_freq):
        self.center_freq = center_freq
        self.NANO_SDR.set_center_freq(self.center_freq, 0)
        self.qtgui_sink_x_0.set_frequency_range(self.center_freq, self.samp_rate)


def main(top_block_cls=receive_and_track, options=None):

    from distutils.version import StrictVersion
    if StrictVersion(Qt.qVersion()) >= StrictVersion("4.5.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()
    tb.start()
    tb.show()

    def quitting():
        tb.stop()
        tb.wait()
    qapp.connect(qapp, Qt.SIGNAL("aboutToQuit()"), quitting)
    qapp.exec_()


if __name__ == '__main__':
    main()
