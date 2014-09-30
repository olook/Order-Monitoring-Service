# -*- encoding : utf-8 -*-
require 'savon'

module Abacos
    
  ABACOS_CONFIG = YAML.load_file(File.dirname(__FILE__)+"/../../"+"config/abacos.yml")

  module Helpers
    API_KEY = ABACOS_CONFIG["key"]

    def find_in_descritor_pre_definido(data, query)
      items = parse_nested_data(data, :dados_descritor_pre_definido)

      items.each do |item|
        return item[:descricao].strip if item[:grupo_nome].strip == query
      end
      ''
    end

    def parse_category(abacos_category)
      case abacos_category.strip.downcase
        when 'sapato' then Category::SHOE
        when 'bolsa' then Category::BAG
      else
        Category::ACCESSORY
      end
    end

    def call_webservice(wsdl, method, params = { "ChaveIdentificacao" => API_KEY })
      client = Savon.client(wsdl: wsdl, read_timeout: 3000, log: false)
      xml = client.call(method.to_sym, :message => params)

      response = xml.to_hash["#{method}_response".to_sym]["#{method}_result".to_sym]

      # TODO: refactor method to make this response check optional
      # raise_webservice_error(response) if response[:resultado_operacao].nil?

      response
    end

    def raise_webservice_error(response)
      raise "Error calling webservice #{response[:method]}: (#{response[:codigo]}) #{response[:tipo]} - #{response[:descricao]} - #{response[:exception_message]}"
    end

    # The Abacos API may return invalid nested data inside a valid response
    def parse_nested_data(data, key)
      call_response = data[:resultado_operacao][:tipo]

      case call_response
        when 'tdreSucesso'
          parsed_data = data[:rows][key]
          parsed_data = [parsed_data] unless parsed_data.is_a? Array
          return parsed_data.compact
        when 'tdreSucessoSemDados'
          return []
      else
        raise "Nested data \"#{data}\" is invalid"
      end
    end

    def download_xml(method, data_key)
      data = call_webservice(self.wsdl, method)
      parse_nested_data data, data_key
    end

    def parse_cpf(cpf)
      cpf.gsub(/-|\.|\s/, '')[0..10]
    end

    def parse_data(birthday)
      return "01011900"  if birthday.nil? # TODO: Emergency fix , should be replaced!
      birthday.strftime "%d%m%Y"
    end

    def parse_datetime(datetime)
      datetime.strftime "%d%m%Y %H:%M:%S"
    end

    def parse_telefone(telephone)
      telephone[0..14]
    end

    def parse_price(price)
      "%.2f" % (price || 0)
    end

    def parse_endereco(address)
      Abacos::Endereco.new(address)
    end
  end
end
