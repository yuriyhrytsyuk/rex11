require 'builder'
require 'xmlsimple'
require 'net/http'

module Rex11
  class Client

    TEST_HOST = 'sync.rex11.com'
    TEST_PATH = '/ws/v2staging/publicapiws.asmx'
    LIVE_HOST = 'sync.rex11.com'
    LIVE_PATH = '/ws/v2prod/publicapiws.asmx'

    attr_accessor :auth_token

    def initialize(username, password, web_address, testing = false, options = {})
      raise 'Username is required' unless username
      raise 'Password is required' unless password

      default_options = {
          :logging => true,
      }
      @options = default_options.update(options)

      @username = username
      @password = password
      @web_address = web_address

      @logging = options[:logging]
      @host = testing ? TEST_HOST : LIVE_HOST
      @path = testing ? TEST_PATH : LIVE_PATH

    end

    def authenticate
      xml_request = soap_body do |xml_request|
        xml_request.AuthenticationTokenGet(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.WebAddress(@web_address)
          xml_request.UserName(@username)
          xml_request.Password(@password)
        end
      end
      parse_authenticate_response(commit(xml_request))
    end

    def style_master_product_add(item)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.StyleMasterProductAdd(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.products do |xml_request|
            xml_request.StyleMasterProduct do |xml_request|
              xml_request.Style(item[:style], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
              xml_request.UPC(item[:upc], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
              xml_request.Size(item[:size], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
              xml_request.Color(item[:color], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
              xml_request.Description(item[:description], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
              xml_request.Price(item[:price], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
            end
          end
        end
      end
      parse_add_style_response(commit(xml_request))
    end

    def style_master_products_add(items)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.StyleMasterProductAdd(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.products do |xml_request|
            items.each do |item|
              xml_request.StyleMasterProduct do |xml_request|
                xml_request.Style(item[:style], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
                xml_request.UPC(item[:upc], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
                xml_request.Size(item[:size], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
                xml_request.Color(item[:color], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
                xml_request.Description(item[:description], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
                xml_request.Price(item[:price], xmlns: 'http://rex11.com/swpublicapi/StyleMasterProduct.xsd')
              end
            end
          end
        end
      end
      parse_add_style_response(commit(xml_request))
    end

    def get_style_master_product_add_status(upc)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetStyleMasterProductAddStatus(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.UPC(upc)
        end
      end
      parse_get_style_master_product_add_status_response(commit(xml_request))
    end

    def pick_ticket_add(items, ship_to_address, pick_ticket_options)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.PickTicketAdd(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.PickTicket(xmlns: 'http://rex11.com/swpublicapi/PickTicket.xsd') do |xml_request|
            xml_request.PickTicketNumber(pick_ticket_options[:pick_ticket_id])
            xml_request.OrderNumber(pick_ticket_options[:order_number])
            xml_request.WareHouse(pick_ticket_options[:warehouse])
            xml_request.PaymentTerms(pick_ticket_options[:payment_terms])
            xml_request.UseAccountUPS(pick_ticket_options[:use_ups_account])
            xml_request.ShipViaAccountNumber(pick_ticket_options[:ship_via_account_number])
            xml_request.ShipVia(pick_ticket_options[:ship_via])
            xml_request.ShipService(pick_ticket_options[:ship_service])
            xml_request.BillingOption(pick_ticket_options[:billing_option])
            xml_request.BillToAddress do |xml_request|
              xml_request.FirstName(pick_ticket_options[:bill_to_address][:first_name], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.LastName(pick_ticket_options[:bill_to_address][:last_name], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.CompanyName(pick_ticket_options[:bill_to_address][:company_name], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Address1(pick_ticket_options[:bill_to_address][:address1], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Address2(pick_ticket_options[:bill_to_address][:address2], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.City(pick_ticket_options[:bill_to_address][:city], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.State(pick_ticket_options[:bill_to_address][:state], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Zip(pick_ticket_options[:bill_to_address][:zip], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Country(pick_ticket_options[:bill_to_address][:country], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Phone(pick_ticket_options[:bill_to_address][:phone], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Email(pick_ticket_options[:bill_to_address][:email], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
            end
            xml_request.ShipToAddress do |xml_request|
              xml_request.FirstName(ship_to_address[:first_name], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.LastName(ship_to_address[:last_name], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.CompanyName(ship_to_address[:company_name], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Address1(ship_to_address[:address1], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Address2(ship_to_address[:address2], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.City(ship_to_address[:city], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.State(ship_to_address[:state], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Zip(ship_to_address[:zip], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Country(ship_to_address[:country], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Phone(ship_to_address[:phone], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Email(ship_to_address[:email], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
            end

            items.each do |item|
              xml_request.LineItem do |xml_request|
                xml_request.UPC(item[:upc], xmlns: 'http://rex11.com/swpublicapi/PickTicketDetails.xsd')
                xml_request.Quantity(item[:quantity], xmlns: 'http://rex11.com/swpublicapi/PickTicketDetails.xsd')
              end
            end
          end
        end
      end
      parse_pick_ticket_add_response(commit(xml_request))
    end

    def get_pick_ticket_statuses_by_date(start_date, end_date)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetPickTicketStatusesByDate(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.StartDate(start_date)
          xml_request.EndDate(end_date)
        end
      end
      parse_get_pick_ticket_statuses_by_date(commit(xml_request))
    end

    def parse_get_pick_ticket_statuses_by_date(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification', 'ShipmentStatus'])
      response_content = response['Body']['GetPickTicketStatusesByDateResponse']['GetPickTicketStatusesByDateResult']

      tickets = response_content['PickTicketStatus']
      if tickets and !tickets.empty?
        tickets['ShipmentStatus'].map do |item|
          {
              ticket_id: item['TicketId'],
              ticket_status: item['TicketStatus'],
              status_code: item['StatusCode'],
              tracking_numbers: item['TrackingNumbers']['string'].is_a?(Hash) ? nil : item['TrackingNumbers']['string'],
          }
        end
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def get_pick_ticket_add_status(pick_ticket_id)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetPickTicketAddStatus(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.authenticationString(@auth_token)
          xml_request.pickTicketNumber(pick_ticket_id)
        end
      end
      parse_get_pick_ticket_add_status(commit(xml_request))
    end

    def parse_get_pick_ticket_add_status(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']['GetPickTicketAddStatusResponse']['GetPickTicketAddStatusResult']
      error_string = parse_error(response_content)

      if error_string.empty?
        ticket_status = response_content['PickTicketStatus']
        {
            :pick_ticket_number => ticket_status['PickTicketNumber'],
            :status_code => ticket_status['StatusCode'],
            :status => ticket_status['Status'],
            :status_details => ticket_status['StatusDetails'],
        }
      else
        raise error_string
      end

    end

    def cancel_pick_ticket(pick_ticket_id)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.CancelPickTicket(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.PickTicketId(pick_ticket_id)
        end
      end
      parse_cancel_pick_ticket(commit(xml_request))
    end

    def parse_cancel_pick_ticket(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']['CancelPickTicketResponse']['CancelPickTicketResult']
      error_string = parse_error(response_content)

      if error_string.empty?
        true
      else
        raise error_string
      end

    end

    def get_pick_ticket_object_by_bar_code(pick_ticket_id)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetPickTicketObjectByBarCode(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.ptbarcode(pick_ticket_id)
        end
      end
      parse_get_pick_ticket_object_by_bar_code(commit(xml_request))
    end

    def receiving_ticket_add(items, receiving_ticket_options)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.ReceivingTicketAdd(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.receivingTicket(xmlns: 'http://rex11.com/swpublicapi/ReceivingTicket.xsd') do |xml_request|
            items.each do |item|
              xml_request.Shipmentitemslist do |xml_request|
                xml_request.Style(item[:style], xmlns: 'http://rex11.com/swpublicapi/ReceivingTicketItems.xsd')
                xml_request.UPC(item[:upc], xmlns: 'http://rex11.com/swpublicapi/ReceivingTicketItems.xsd')
                xml_request.Size(item[:size], xmlns: 'http://rex11.com/swpublicapi/ReceivingTicketItems.xsd')
                xml_request.Color(item[:color], xmlns: 'http://rex11.com/swpublicapi/ReceivingTicketItems.xsd')
                xml_request.ProductDescription(item[:description], xmlns: 'http://rex11.com/swpublicapi/ReceivingTicketItems.xsd')
                xml_request.ExpectedQuantity(item[:quantity], xmlns: 'http://rex11.com/swpublicapi/ReceivingTicketItems.xsd')
                xml_request.Comments(item[:comments], xmlns: 'http://rex11.com/swpublicapi/ReceivingTicketItems.xsd')
                xml_request.ShipmentType(item[:shipment_type], xmlns: 'http://rex11.com/swpublicapi/ReceivingTicketItems.xsd')
              end
            end
            items.map{|i| i[:shipment_type]}.uniq.each do |shipment_type|
              xml_request.ShipmentTypelist(shipment_type)
            end
            xml_request.Warehouse(receiving_ticket_options[:warehouse])
            xml_request.Memo(receiving_ticket_options[:memo])
            xml_request.Carrier(receiving_ticket_options[:carrier])
            xml_request.SupplierDetails do |xml_request|
              xml_request.CompanyName(receiving_ticket_options[:supplier][:company_name], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Address1(receiving_ticket_options[:supplier][:address1], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Address2(receiving_ticket_options[:supplier][:address2], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.City(receiving_ticket_options[:supplier][:city], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.State(receiving_ticket_options[:supplier][:state], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Zip(receiving_ticket_options[:supplier][:zip], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Country(receiving_ticket_options[:supplier][:country], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Phone(receiving_ticket_options[:supplier][:phone], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
              xml_request.Email(receiving_ticket_options[:supplier][:email], xmlns: 'http://rex11.com/swpublicapi/CustomerOrder.xsd')
            end
          end
        end
      end
      parse_receiving_ticket_add_response(commit(xml_request))
    end

    def get_receiving_ticket_add_status(receiving_ticket_id)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetReceivingTicketAddStatus(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.authenticationString(@auth_token)
          xml_request.receivingTicketId(receiving_ticket_id)
        end
      end
      parse_get_receiving_ticket_add_status_response(commit(xml_request))
    end

    def get_receiving_statuses_by_date_configurable(start_date, end_date, date_type)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetReceivingStatusesByDateConfigurable(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.StartDate(start_date)
          xml_request.EndDate(end_date)
          xml_request.dateType(date_type)
        end
      end
      parse_get_receiving_statuses_by_date_configurable_response(commit(xml_request))
    end

    def get_receiving_ticket_object_by_ticket_no(receiving_ticket_id)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetReceivingTicketObjectByTicketNo(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.AsnTicketNumber(receiving_ticket_id)
        end
      end
      parse_get_receiving_ticket_object_by_ticket_number(commit(xml_request))
    end

    def get_inventory
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetInventory(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
        end
      end
      parse_get_inventory(commit(xml_request))
    end

    def get_inventory_by_style(style_number)
      require_auth_token
      xml_request = soap_body do |xml_request|
        xml_request.GetInventoryByStyle(xmlns: 'http://rex11.com/webmethods/') do |xml_request|
          xml_request.AuthenticationString(@auth_token)
          xml_request.style(style_number)
        end
      end
      parse_get_inventory_by_style(commit(xml_request))
    end

    def parse_get_inventory(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']['GetInventoryResponse']['GetInventoryResult']

      inventory = response_content['Inventory']
      if inventory and !inventory.empty?
        inventory['item'].map do |item|
          {
              warehouse: item['Warehouse'],
              sku: item['Sku'],
              style: item['Style'],
              color: item['Color'],
              size: item['Size'],
              upc: item['Upc'],
              description: item['Description'],
              price: item['Price'],
              actual_quantity: item['ActualQuantity'],
              pending_quantity: item['PendingQuantity'],
          }
        end
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def parse_get_inventory_by_style(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']['GetInventoryByStyleResponse']['GetInventoryByStyleResult']

      inventory = response_content['Inventory']
      if inventory and !inventory.empty?
        inventory['item'].map do |item|
          {
              warehouse: item['Warehouse'],
              sku: item['Sku'],
              style: item['Style'],
              color: item['Color'],
              size: item['Size'],
              upc: item['Upc'],
              description: item['Description'],
              price: item['Price'],
              actual_quantity: item['ActualQuantity'],
              pending_quantity: item['PendingQuantity'],
          }
        end
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    private
    def commit(xml_request)
      http = Net::HTTP.new(@host, 80)
      response = http.post(@path, xml_request.target!, {'Content-Type' => 'text/xml'})
      puts response.body if @options[:logging]
      response.body
    end

    def require_auth_token
      authenticate unless @auth_token
      raise 'Authentication required for api call' unless @auth_token
    end

    def parse_authenticate_response(xml_response)
      response = XmlSimple.xml_in(xml_response, :ForceArray => false)
      response_content = response['Body']['AuthenticationTokenGetResponse']['AuthenticationTokenGetResult']
      if response_content and !response_content.empty?
        @auth_token = response_content
        true
      else
        raise 'Failed Authentication due invalid username, password, or endpoint'
      end
    end

    def parse_add_style_response(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']['StyleMasterProductAddResponse']['StyleMasterProductAddResult']
      error_string = parse_error(response_content)

      if error_string.empty?
        true
      else
        raise error_string
      end
    end

    def parse_get_style_master_product_add_status_response(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']['GetStyleMasterProductAddStatusResponse']['GetStyleMasterProductAddStatusResult']
      error_string = parse_error(response_content)

      if error_string.empty?
        true
      else
        raise error_string
      end
    end

    def parse_pick_ticket_add_response(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']['PickTicketAddResponse']['PickTicketAddResult']
      error_string = parse_error(response_content)

      if error_string.empty?
        true
      else
        raise error_string
      end
    end

    def parse_get_pick_ticket_object_by_bar_code(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']['GetPickTicketObjectByBarCodeResponse']['GetPickTicketObjectByBarCodeResult']

      pick_ticket_hash = response_content['PickTicket']
      if pick_ticket_hash and !pick_ticket_hash.empty?
        return_hash = {
            :pick_ticket_id => (value = pick_ticket_hash['PickTicketNumber']) ? value['content'] : nil,
            :pick_ticket_status => (value = pick_ticket_hash['ShipmentStatus']) ? value['content'] : nil,
            :pick_ticket_status_code => (value = pick_ticket_hash['ShipmentStatusCode']) ? value['content'] : nil,
            :shipping_charge => (value = pick_ticket_hash['FreightCharge']) ? value['content'] : nil,
            :tracking_number => (package_list = pick_ticket_hash['PackageList']) ? package_list['TrackingNumber'] : nil
        }
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def parse_receiving_ticket_add_response(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']["ReceivingTicketAddResponse"]["ReceivingTicketAddResult"]

      receiving_ticket_id = response_content["ReceivingTicketId"]
      if receiving_ticket_id and !receiving_ticket_id.empty?
        {:receiving_ticket_id => receiving_ticket_id}
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def parse_get_receiving_ticket_add_status_response(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification'])
      response_content = response['Body']["GetReceivingTicketAddStatusResponse"]["GetReceivingTicketAddStatusResult"]

      receiving_ticket_status = response_content["ReceivingTicketStatus"]
      if receiving_ticket_status and !receiving_ticket_status.empty?
        {
            :ticket_id => receiving_ticket_status["TicketId"],
            :ticket_status => receiving_ticket_status["TicketStatus"],
            :status_code => receiving_ticket_status["StatusCode"],
            :status_description => receiving_ticket_status["StatusDescription"],
        }
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def parse_get_receiving_statuses_by_date_configurable_response(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification', 'ReceivingTicketShipmentStatus'])
      response_content = response['Body']["GetReceivingStatusesByDateConfigurableResponse"]["GetReceivingStatusesByDateConfigurableResult"]

      receiving_ticket_status = response_content["ReceivingTicketStatus"]
      if receiving_ticket_status and !receiving_ticket_status.empty?
        result = receiving_ticket_status["ReceivingTicketShipmentStatus"].map do |item|
          {
              :ticket_id => item["TicketId"],
              :ticket_status => item["TicketStatus"],
              :status_code => item["StatusCode"],
          }
        end
        return result
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def parse_get_receiving_ticket_object_by_ticket_number(xml_response)
      response = XmlSimple.xml_in(xml_response, ForceArray: ['Notification', 'Shipmentitemslist'])
      response_content = response['Body']["GetReceivingTicketObjectByTicketNoResponse"]["GetReceivingTicketObjectByTicketNoResult"]

      receiving_ticket_hash = response_content["ReceivingTicketByTicketNo"]
      if receiving_ticket_hash and !receiving_ticket_hash.empty?

        items = receiving_ticket_hash["ReceivingTicket"]["Shipmentitemslist"].map do |item|
          {
              :style => item["Style"]['content'],
              :upc => item["UPC"]['content'],
              :size => item["Size"]['content'],
              :color => item["Color"]['content'],
              :description => item["ProductDescription"]['content'],
              :quantity => item["ActualQuantity"]['content'],
              :expected_quantity => item["ExpectedQuantity"]['content'],
              :shipment_type => item["ShipmentType"]['content']
          }
        end

        return_hash = {
            :receiving_ticket_status => (value = receiving_ticket_hash["ReceivingTicket"]["ReceivingStatus"]) ? value['content'] : nil,
            :receiving_ticket_status_code => (value = receiving_ticket_hash["ReceivingTicket"]["ReceivingStatusCode"]) ? value['content'] : nil,
            :items => items
        }
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def parse_error(response_content)
      return '' if response_content['Notifications'].nil?
      return '' if response_content['Notifications']['Notification'].nil?
      response_content['Notifications']['Notification'].map do |notification|
        if notification['ErrorCode'] != '0'
          "Error #{notification['ErrorCode']}: #{notification['Message']}."
        end
      end.compact.join(' ')
    end

    alias_method :pick_ticket_by_number,                   :get_pick_ticket_object_by_bar_code
    alias_method :receiving_ticket_by_receiving_ticket_id, :get_receiving_ticket_object_by_ticket_no
    alias_method :create_pick_ticket,                      :pick_ticket_add
    alias_method :create_receiving_ticket,                 :receiving_ticket_add
    alias_method :add_style,                               :style_master_product_add

    private

    def soap_body
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.soap :Envelope,
               :'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
               :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
               :'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do
        xml.soap :Body do
          yield xml
        end
      end
      xml
    end
  end
end
