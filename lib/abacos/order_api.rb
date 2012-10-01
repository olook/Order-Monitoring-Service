# -*- encoding : utf-8 -*-
require 'helpers'

module Abacos
  class OrderAPI
    extend Helpers

    def self.wsdl
      ABACOS_CONFIG["wsdl_order_api"]
    end

    def self.order_exists?(order_number)
      status = {}
      payload = {'ListaDeNumerosDePedidos' => {'string' => order_number}}
      payload["ChaveIdentificacao"] = Abacos::Helpers::API_KEY
      response = call_webservice(wsdl, :pedido_existe, payload)
      status[response[:rows][:dados_pedidos_existentes][:status_atual]] = response[:rows][:dados_pedidos_existentes][:existente]
      status
    end

  end
end