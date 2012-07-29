con     ' Setup clocks
  _clkmode = xtal1 + pll4x                                      ' run @ 20MHz in XTAL mode
  _xinfreq = 5_000_000                                          ' use 5MHz crystal

  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MS_001   = CLK_FREQ / 1_000
  US_001   = CLK_FREQ / 1_000_000
obj     ' Load object files
  serial    :    "FullDuplexSerial64"
  ir_rx     :    "sircs_rx"
  ir_tx     :    "sircs_tx"
  leds      :    "pwm8"
con     ' Chip and pin definitions
'' Propeller pin definitions
''
'' LEDs share with VGA
''
  RX1  = 31                                                     ' programming / terminal
  TX1  = 30

  SDA  = 29                                                     ' eeprom / i2c
  SCL  = 28

  MS_D = 27                                                     ' ps/2 mouse
  MS_C = 26

  KB_D = 25                                                     ' ps/2 keyboard
  KB_C = 24

  LED8 = 23                                                     ' leds / vga
  LED7 = 22
  LED6 = 21
  LED5 = 20
  LED4 = 19
  LED3 = 18
  LED2 = 17
  LED1 = 16                                             ' base pin for vga dac

  IRTX = 13                                                     ' ir led
  IRRX = 12                                                     ' ir demodulator
con     ' Local constants
  EEPROM    = $A0
  DEBUG     = 1
var     ' Global variables
pub main | ir_rx_byte, ir_tx_byte
  leds.start(8, LED1)           ' 8 LEDs, starting at pin #PIN1
  serial.start(RX1, TX1, 0, 115200)
  ir_rx.start(IRRX)
  pause(5)                      ' give the drivers a moment to initialize

  leds.set_all($FF)
  serial.str(string("OHAI"))
  newline
  pause(150)
  leds.set_all(0)
  leds.set(7, $FF)

  repeat
    ir_rx_byte := ir_rx.rx      ' According to sircs_rx.spin, this blocks
    leds.toggle(0)
    serial.hex(ir_rx_byte, 1)
    newline

pri newline
  serial.tx(13)
  serial.tx(10)
pri pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)

