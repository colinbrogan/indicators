module Indicators
  #
  # Simple Moving Average
  class PSar


    def resetAF
      @af = 0.02
    end

    def flipRising
      @rising = !@rising
    end

    # RSI: (Exponential race from one peak to another trough)
    def self.calculate data, parameters
      periods = parameters
      output = Array.new
      # Returns an array from the requested column and checks if there is enought data points.
      ohlc_data = Indicators::Helper.validate_data(data, :ohlc, periods)

      resetAF
      highest_high = nil
      lowest_low = nil

      rising = nil
      ep == nil

      ohlc_data.each_with_index do |ohlc_datum, index|
      	if index > periods
          prev_psar = output[index-1]
          updateRisingAndAF prev_psar, ohlc_datum, ep

          if rising
            output[index] = prev_psar + (af*(ep - prev_psar))
          else
            output[index] = prev_psar - (af*(prev_psar - ep))
          end
          ep = updateEP(ep,ohlc_datum,rising)
      	elsif index == periods
          rising = ohlc_data[0][:open] <= ohlc_data[periods][:close]
          ep = rising ? highest_high : lowest_low
          output[index] = ep
        else
          lowest_low = updateEP(lowest_low,ohlc_datum,true)
          highest_high = updateEP(highest_high,ohlc_datum,true)
      		output[index] = nil
      	end
      end
      return output
    end
  end
  def updateEP(prev_ep,ohlc_datum, rising)
    if rising and (prev_ep == nil or ohlc_datum[:high] > prev_ep)
      ep = ohlc_datum[:high]
    elsif !rising and (prev_ep == nil or ohlc_datum[:low] < prev_ep)
      ep = ohlc_datum[:low]
    end
    return ep
  end
  def updateRisingAndAF(prev_psar, ohlc_datum, prev_ep)
    if prev_psar == nil
      prev_psar = prev_ep
      resetAF
    elsif rising and prev_psar > ohlc_datum[:low]
      prev_psar = prev_ep
      resetAF
      flipRising
    elsif !rising and prev_psar < ohlc_datum[:high]
      prev_psar = prev_ep
      resetAF
      flipRising
    end
  end
end