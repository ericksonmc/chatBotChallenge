class MindicadorServices

  def initialize(indicator)
    @indicator = indicator
  end

  def find_indicators
    
    url = "https://mindicador.cl/api/#{@indicator.downcase}"
    response = HTTParty.get(url)
    return get_response(response)
  end

  private

  def get_response(request)
    data = JSON.parse(request.body)
    "El valor del indicador #{@indicator} es de: #{data["serie"][0]["valor"]} #{data['unidad_medida']}"
  end
end