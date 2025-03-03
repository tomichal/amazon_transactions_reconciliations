#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rtesseract'
require 'pdf-reader'
require 'csv'

class Reconciliator
  @card_charges = []
  @amazon_orders = []

  def run
    @card_charges = card_charges
    @amazon_orders = amazon_orders

    write_csv
  end

  private

  def write_csv

    Dir.mkdir('./output') unless Dir.exist?('./output') # Ensure 'output' directory exists
    
    CSV.open('./output/reconcile.csv', 'w') do |csv|
      csv << ['Card Charge Order Number', 'Order Number', 'Order Date', 'Order Details', 'Who', 'Order Price', 'Card Charge Amount'] # Headers for the CSV
      @card_charges.each do |card_charge|
        order = @amazon_orders.find { |order| order[:order_number] == card_charge[:order_number] }
        csv << [
          card_charge[:order_number],

          (order ? order[:order_number] : "Amazon order not found"),
          (order ? order[:order_date] : "Amazon order not found"),
          (order ? order[:order_details] : "Amazon order not found"),
          (order ? order[:who] : "Amazon order not found"),

          (order ? order[:order_price] : "Amazon order not found"),

          card_charge[:order_charge],
        ]
      end
    end

    CSV.open('./output/amazon_orders.csv', 'w') do |csv|
      csv << ['Order Number', 'Order Date', 'Order Price', 'Order Details'] # Headers for the CSV
      @amazon_orders.each do |order|
        csv << [
          (order ? order[:order_number] : "Amazon order not found"),
          (order ? order[:order_date] : "Amazon order not found"),
          (order ? order[:order_price] : "Amazon order not found"),
          (order ? order[:order_details] : "Amazon order not found")
        ]
      end
    end
  end

  def card_charges
    charges = []
    Dir.glob('./input/*/statements/*.pdf').each do |file|
      reader = PDF::Reader.new(file)
      extracted_text = reader.pages.map(&:text).join("\n")

      extracted_text.scan(/Order Number\s*(\d*?)-(\d*?)-(\d*)/).each do |match|
        order_number = match.join('-')

        lines = extracted_text.lines.reject { |l| l.strip.empty? }
        line_indices = lines.each_index.select { |i| lines[i].include?(order_number) }
        line_indices.each do |line_index|
          preceding_line = line_index && line_index.positive? ? lines[line_index - 1].strip : nil
          order_charge = preceding_line&.match(/([0-9]+?)\.([0-9]{2})/)&.[](0)

          charges << {
            order_number:,
            order_charge:
          }
        end
      end
    end
    charges
  end

  def amazon_orders
    orders = []
    Dir.glob('./input/*/orders/**/*.png').each do |file|
      who = file.split('/')[-2]
      ocr = RTesseract.new(file, lang: 'eng')
      extracted_text = ocr.to_s
      order_infos = extracted_text.split("ORDER PLACED")
      order_infos.each do |order_info|
        next if order_info.empty?
        order_number = order_info.match(/ORDER # (\d{3}-\d{7}-\d{7})/)&.[](1)
        order_date = order_info.lines[1].match(/^(.*?),/)&.[](1)
        order_details = order_info.lines[2..-1].join("\n").strip
        order_price = order_info.lines[1].match(/\$[0-9]+\.[0-9]{2}/)&.[](0)

        orders << {
          order_number:,
          order_date:,
          order_price:,
          order_details:,
          who:
        }
      end
    end
    orders
  end
end

Reconciliator.new.run